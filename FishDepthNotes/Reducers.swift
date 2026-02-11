import Foundation

func appReducer(state: AppState, action: AppAction) -> AppState {
    var newState = state
    
    switch action {
    case .initialize:
        newState.phase = .loading
        
    case .timeout:
        newState.phase = .paused
        newState.ui.navigateMain = true
        
    case .trackingReceived(let data):
        let converted = convertToStringDict(data)
        newState.config.tracking = AppState.Config.TrackingInfo(data: converted)
        
    case .navigationReceived(let data):
        let converted = convertToStringDict(data)
        newState.config.navigation = AppState.Config.NavigationInfo(data: converted)
        
    case .networkStatusChanged(let isConnected):
        newState.ui.showOfflineView = !isConnected
        
    case .validationStarted:
        newState.phase = .checking
        
    case .validationSuccess:
        newState.phase = .approved
        
    case .validationFailure:
        newState.phase = .paused
        newState.ui.navigateMain = true
        
    case .fetchTrackingStarted:
        break
        
    case .fetchTrackingSuccess(let data):
        let converted = convertToStringDict(data)
        newState.config.tracking = AppState.Config.TrackingInfo(data: converted)
        
    case .fetchTrackingFailure:
        newState.phase = .paused
        newState.ui.navigateMain = true
        
    case .fetchEndpointStarted:
        break
        
    case .fetchEndpointSuccess(let endpoint):
        newState.config.endpoint = endpoint
        newState.config.mode = "Active"
        newState.config.firstLaunch = false
        newState.phase = .running(endpoint)
        
        if newState.config.notifications.canAsk {
            newState.ui.showNotificationPrompt = true
        } else {
            newState.ui.navigateWeb = true
        }
        
    case .fetchEndpointFailure:
        if let saved = newState.config.endpoint {
            newState.phase = .running(saved)
            
            if newState.config.notifications.canAsk {
                newState.ui.showNotificationPrompt = true
            } else {
                newState.ui.navigateWeb = true
            }
        } else {
            newState.phase = .paused
            newState.ui.navigateMain = true
        }
        
    case .notificationPermissionRequested:
        break
        
    case .notificationPermissionGranted:
        newState.config.notifications = AppState.Config.NotificationInfo(
            status: .approved,
            lastRequest: Date()
        )
        newState.ui.showNotificationPrompt = false
        newState.ui.navigateWeb = true
        
    case .notificationPermissionDenied:
        newState.config.notifications = AppState.Config.NotificationInfo(
            status: .rejected,
            lastRequest: Date()
        )
        newState.ui.showNotificationPrompt = false
        newState.ui.navigateWeb = true
        
    case .notificationPromptDismissed:
        newState.config.notifications = AppState.Config.NotificationInfo(
            status: .notAsked,
            lastRequest: Date()
        )
        newState.ui.showNotificationPrompt = false
        newState.ui.navigateWeb = true
        
    case .navigateToMain:
        newState.ui.navigateMain = true
        
    case .navigateToWeb:
        newState.ui.navigateWeb = true
        
    case .configLoaded(let config):
        newState.config.endpoint = config.endpoint
        newState.config.mode = config.mode
        newState.config.firstLaunch = config.firstLaunch
        newState.config.tracking = AppState.Config.TrackingInfo(data: config.tracking)
        newState.config.navigation = AppState.Config.NavigationInfo(data: config.navigation)
        
        let status: AppState.Config.NotificationInfo.Status
        if config.notifications.approved {
            status = .approved
        } else if config.notifications.rejected {
            status = .rejected
        } else {
            status = .notAsked
        }
        
        newState.config.notifications = AppState.Config.NotificationInfo(
            status: status,
            lastRequest: config.notifications.lastRequest
        )
        
    case .configSaved:
        break
    }
    
    return newState
}

private func convertToStringDict(_ dict: [String: Any]) -> [String: String] {
    var result: [String: String] = [:]
    for (key, value) in dict {
        result[key] = "\(value)"
    }
    return result
}
