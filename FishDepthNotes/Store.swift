import Foundation
import Combine
import UIKit
import UserNotifications
import Network
import AppsFlyerLib

@MainActor
final class Store: ObservableObject {
    
    @Published var state: AppState = .initial
    
    private let persistence: PersistenceLayer
    private let validator: Validator
    private let backend: Backend
    
    private var timeoutTask: Task<Void, Never>?
    private var isLocked = false
    
    private let networkMonitor = NWPathMonitor()
    
    init(
        persistence: PersistenceLayer = DiskPersistence(),
        validator: Validator = FirebaseValidator(),
        backend: Backend = HTTPBackend()
    ) {
        self.persistence = persistence
        self.validator = validator
        self.backend = backend
        
        setupNetworkMonitor()
        loadConfig()
    }
    
    func dispatch(_ action: AppAction) {
        let oldState = state
        let newState = appReducer(state: oldState, action: action)
        state = newState
        
        // Side effects
        handleSideEffects(action: action, oldState: oldState, newState: newState)
    }
    
    // MARK: - Side Effects
    private func handleSideEffects(action: AppAction, oldState: AppState, newState: AppState) {
        switch action {
        case .initialize:
            scheduleTimeout()
            
        case .trackingReceived:
            persistence.save(tracking: newState.config.tracking.data)
            Task { await performValidation() }
            
        case .navigationReceived:
            persistence.save(navigation: newState.config.navigation.data)
            
        case .validationSuccess:
            Task { await executeBusinessLogic() }
            
        case .fetchTrackingSuccess:
            persistence.save(tracking: newState.config.tracking.data)
            Task { await requestEndpoint() }
            
        case .fetchEndpointSuccess(let endpoint):
            persistence.save(endpoint: endpoint)
            persistence.save(mode: "Active")
            persistence.markFirstLaunchDone()
            
        case .notificationPermissionRequested:
            requestNotificationPermission()
            
        case .notificationPermissionGranted:
            let config = NotificationConfig(
                approved: true,
                rejected: false,
                lastRequest: Date()
            )
            persistence.save(notifications: config)
            UIApplication.shared.registerForRemoteNotifications()
            
        case .notificationPermissionDenied:
            let config = NotificationConfig(
                approved: false,
                rejected: true,
                lastRequest: Date()
            )
            persistence.save(notifications: config)
            
        case .notificationPromptDismissed:
            let config = NotificationConfig(
                approved: false,
                rejected: false,
                lastRequest: Date()
            )
            persistence.save(notifications: config)
            
        default:
            break
        }
    }
    
    private func loadConfig() {
        let loaded = persistence.load()
        
        let config = AppAction.Config(
            endpoint: loaded.endpoint,
            mode: loaded.mode,
            firstLaunch: loaded.isFirstLaunch,
            tracking: loaded.tracking,
            navigation: loaded.navigation,
            notifications: AppAction.Config.NotificationConfig(
                approved: loaded.notifications.approved,
                rejected: loaded.notifications.rejected,
                lastRequest: loaded.notifications.lastRequest
            )
        )
        
        dispatch(.configLoaded(config))
    }
    
    private func scheduleTimeout() {
        timeoutTask = Task {
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            
            guard !isLocked else { return }
            
            await MainActor.run {
                self.dispatch(.timeout)
            }
        }
    }
    
    private func setupNetworkMonitor() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self = self, !self.isLocked else { return }
                self.dispatch(.networkStatusChanged(path.status == .satisfied))
            }
        }
        networkMonitor.start(queue: .global(qos: .background))
    }
    
    private func performValidation() async {
        guard state.config.endpoint == nil else { return }
        
        dispatch(.validationStarted)
        
        do {
            let isValid = try await validator.validate()
            
            if isValid {
                dispatch(.validationSuccess)
            } else {
                dispatch(.validationFailure)
            }
        } catch {
            dispatch(.validationFailure)
        }
    }
    
    private func executeBusinessLogic() async {
        guard state.config.tracking.hasContent else {
            loadSavedEndpoint()
            return
        }
        
        if let temp = UserDefaults.standard.string(forKey: "temp_url") {
            completeWithURL(temp)
            return
        }
        
        if shouldRunOrganicFlow() {
            await runOrganicFlow()
            return
        }
        
        await requestEndpoint()
    }
    
    private func shouldRunOrganicFlow() -> Bool {
        state.config.firstLaunch && state.config.tracking.isOrganic
    }
    
    private func runOrganicFlow() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        do {
            dispatch(.fetchTrackingStarted)
            
            let deviceID = AppsFlyerLib.shared().getAppsFlyerUID()
            let fetched = try await backend.fetchTracking(deviceID: deviceID)
            
            var merged = fetched
            let navigationDict = convertToAnyDict(state.config.navigation.data)
            
            for (key, value) in navigationDict {
                if merged[key] == nil {
                    merged[key] = value
                }
            }
            
            dispatch(.fetchTrackingSuccess(merged))
        } catch {
            dispatch(.fetchTrackingFailure)
        }
    }
    
    private func requestEndpoint() async {
        do {
            dispatch(.fetchEndpointStarted)
            
            let trackingDict = convertToAnyDict(state.config.tracking.data)
            let endpoint = try await backend.fetchEndpoint(tracking: trackingDict)
            
            dispatch(.fetchEndpointSuccess(endpoint))
        } catch {
            dispatch(.fetchEndpointFailure)
        }
    }
    
    private func loadSavedEndpoint() {
        if let saved = state.config.endpoint {
            completeWithURL(saved)
        } else {
            dispatch(.navigateToMain)
        }
    }
    
    private func completeWithURL(_ url: String) {
        guard !isLocked else { return }
        
        timeoutTask?.cancel()
        isLocked = true
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { [weak self] granted, _ in
            Task { @MainActor [weak self] in
                if granted {
                    self?.dispatch(.notificationPermissionGranted)
                } else {
                    self?.dispatch(.notificationPermissionDenied)
                }
            }
        }
    }
    
    private func convertToAnyDict(_ dict: [String: String]) -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, value) in dict {
            result[key] = value
        }
        return result
    }
}
