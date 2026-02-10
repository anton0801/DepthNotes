import Foundation

struct AppState: Equatable {
    var phase: Phase
    var config: Config
    var ui: UIFlags
    
    enum Phase: Equatable {
        case start
        case loading
        case checking
        case approved
        case running(String)
        case paused
        case offline
    }
    
    struct Config: Equatable {
        var endpoint: String?
        var mode: String?
        var firstLaunch: Bool
        var tracking: TrackingInfo
        var navigation: NavigationInfo
        var notifications: NotificationInfo
        
        struct TrackingInfo: Equatable {
            let data: [String: String]
            
            var hasContent: Bool { !data.isEmpty }
            var isOrganic: Bool { data["af_status"] == "Organic" }
            
            static var empty: TrackingInfo {
                TrackingInfo(data: [:])
            }
        }
        
        struct NavigationInfo: Equatable {
            let data: [String: String]
            
            var hasContent: Bool { !data.isEmpty }
            
            static var empty: NavigationInfo {
                NavigationInfo(data: [:])
            }
        }
        
        struct NotificationInfo: Equatable {
            var status: Status
            var lastRequest: Date?
            
            enum Status: Equatable {
                case notAsked
                case approved
                case rejected
            }
            
            var canAsk: Bool {
                guard status == .notAsked else { return false }
                
                if let date = lastRequest {
                    let elapsed = Date().timeIntervalSince(date) / 86400
                    return elapsed >= 3
                }
                return true
            }
            
            static var initial: NotificationInfo {
                NotificationInfo(status: .notAsked, lastRequest: nil)
            }
        }
        
        static var initial: Config {
            Config(
                endpoint: nil,
                mode: nil,
                firstLaunch: true,
                tracking: .empty,
                navigation: .empty,
                notifications: .initial
            )
        }
    }
    
    struct UIFlags: Equatable {
        var showNotificationPrompt: Bool
        var showOfflineView: Bool
        var navigateMain: Bool
        var navigateWeb: Bool
        
        static var initial: UIFlags {
            UIFlags(
                showNotificationPrompt: false,
                showOfflineView: false,
                navigateMain: false,
                navigateWeb: false
            )
        }
    }
    
    static var initial: AppState {
        AppState(
            phase: .start,
            config: .initial,
            ui: .initial
        )
    }
}
