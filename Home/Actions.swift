import Foundation


enum AppAction {
    // Lifecycle
    case initialize
    case timeout
    
    // Data received
    case trackingReceived([String: Any])
    case navigationReceived([String: Any])
    
    // Network
    case networkStatusChanged(Bool)
    
    // Validation
    case validationStarted
    case validationSuccess
    case validationFailure
    
    // Fetching
    case fetchTrackingStarted
    case fetchTrackingSuccess([String: Any])
    case fetchTrackingFailure
    
    case fetchEndpointStarted
    case fetchEndpointSuccess(String)
    case fetchEndpointFailure
    
    // Notifications
    case notificationPermissionRequested
    case notificationPermissionGranted
    case notificationPermissionDenied
    case notificationPromptDismissed
    
    // Navigation
    case navigateToMain
    case navigateToWeb
    
    // Config updates
    case configLoaded(Config)
    case configSaved
    
    struct Config {
        var endpoint: String?
        var mode: String?
        var firstLaunch: Bool
        var tracking: [String: String]
        var navigation: [String: String]
        var notifications: NotificationConfig
        
        struct NotificationConfig {
            var approved: Bool
            var rejected: Bool
            var lastRequest: Date?
        }
    }
}
