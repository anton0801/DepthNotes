import UIKit
import FirebaseCore
import FirebaseMessaging
import AppTrackingTransparency
import UserNotifications
import AppsFlyerLib

final class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    private let attributionBridge = AttributionBridge()
    private let pushBridge = PushBridge()
    private var trackingBridge: TrackingBridge?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        attributionBridge.onTracking = { [weak self] in self?.broadcastTracking($0) }
        attributionBridge.onNavigation = { [weak self] in self?.broadcastNavigation($0) }
        trackingBridge = TrackingBridge(bridge: attributionBridge)
        
        initializeFirebase()
        initializePush()
        initializeTracking()
        
        if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            pushBridge.process(payload: notification)
        }
    
        observeLifecycle()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    private func initializeFirebase() {
        FirebaseApp.configure()
    }
    
    private func initializePush() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func initializeTracking() {
        trackingBridge?.configure()
    }
    
    private func observeLifecycle() {
        NotificationCenter.default.addObserver(self, selector: #selector(becameActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func becameActive() {
        trackingBridge?.start()
    }
    
    private func broadcastTracking(_ data: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: Notification.Name("ConversionDataReceived"), object: nil, userInfo: ["conversionData": data])
    }
    
    private func broadcastNavigation(_ data: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: Notification.Name("deeplink_values"), object: nil, userInfo: ["deeplinksData": data])
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, error in
            guard error == nil, let token = token else { return }
            UserDefaults.standard.set(token, forKey: "fcm_token")
            UserDefaults.standard.set(token, forKey: "push_token")
            UserDefaults(suiteName: "group.depth.store")?.set(token, forKey: "shared_fcm_token")
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "fcm_timestamp")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        pushBridge.process(payload: notification.request.content.userInfo)
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        pushBridge.process(payload: response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        pushBridge.process(payload: userInfo)
        completionHandler(.newData)
    }
    
}

final class PushBridge: NSObject {
    func process(payload: [AnyHashable: Any]) {
        guard let url = extractURL(from: payload) else { return }
        UserDefaults.standard.set(url, forKey: "temp_url")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "temp_url_timestamp")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            NotificationCenter.default.post(name: Notification.Name("LoadTempURL"), object: nil, userInfo: ["temp_url": url])
        }
    }
    
    private func extractURL(from payload: [AnyHashable: Any]) -> String? {
        if let url = payload["url"] as? String { return url }
        if let data = payload["data"] as? [String: Any], let url = data["url"] as? String { return url }
        if let aps = payload["aps"] as? [String: Any], let data = aps["data"] as? [String: Any], let url = data["url"] as? String { return url }
        if let custom = payload["custom"] as? [String: Any], let url = custom["target_url"] as? String { return url }
        return nil
    }
}

final class TrackingBridge: NSObject, AppsFlyerLibDelegate, DeepLinkDelegate {
    private var bridge: AttributionBridge
    
    init(bridge: AttributionBridge) {
        self.bridge = bridge
    }
    
    func configure() {
        let sdk = AppsFlyerLib.shared()
        sdk.appsFlyerDevKey = Settings.devKey
        sdk.appleAppID = Settings.appID
        sdk.delegate = self
        sdk.deepLinkDelegate = self
        sdk.isDebug = false
    }
    
    func start() {
        if #available(iOS 14.0, *) {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    AppsFlyerLib.shared().start()
                    UserDefaults.standard.set(status.rawValue, forKey: "att_status")
                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "att_timestamp")
                }
            }
        } else {
            AppsFlyerLib.shared().start()
        }
    }
    
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        bridge.receiveTracking(data)
    }
    
    func onConversionDataFail(_ error: Error) {
        var data: [AnyHashable: Any] = [:]
        data["error"] = true
        data["error_description"] = error.localizedDescription
        bridge.receiveTracking(data)
    }
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        guard case .found = result.status, let deepLink = result.deepLink else { return }
        bridge.receiveNavigation(deepLink.clickEvent)
    }
}
