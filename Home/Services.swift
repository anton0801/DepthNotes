import Foundation
import FirebaseDatabase
import AppsFlyerLib
import FirebaseCore
import FirebaseMessaging
import WebKit

protocol PersistenceLayer {
    func save(tracking: [String: String])
    func load() -> LoadedConfig
    func save(navigation: [String: String])
    func save(endpoint: String)
    func save(mode: String)
    func markFirstLaunchDone()
    func save(notifications: NotificationConfig)
}

struct LoadedConfig {
    var endpoint: String?
    var mode: String?
    var isFirstLaunch: Bool
    var tracking: [String: String]
    var navigation: [String: String]
    var notifications: NotificationConfig
}

struct NotificationConfig {
    var approved: Bool
    var rejected: Bool
    var lastRequest: Date?
}

final class DiskPersistence: PersistenceLayer {
    
    private let store = UserDefaults(suiteName: "group.depth.store")!
    private let cache = UserDefaults.standard
    private var memory: [String: Any] = [:]
    
    private enum Key {
        static let tracking = "dn_tracking_payload"
        static let navigation = "dn_navigation_payload"
        static let endpoint = "dn_endpoint_target"
        static let mode = "dn_mode_active"
        static let firstLaunch = "dn_first_launch_flag"
        static let notifApproved = "dn_notif_approved"
        static let notifRejected = "dn_notif_rejected"
        static let notifDate = "dn_notif_date"
    }
    
    init() {
        preload()
    }
    
    func save(tracking: [String: String]) {
        if let json = toJSON(tracking) {
            store.set(json, forKey: Key.tracking)
            memory[Key.tracking] = json
        }
    }
    
    func save(navigation: [String: String]) {
        if let json = toJSON(navigation) {
            let encoded = encode(json)
            store.set(encoded, forKey: Key.navigation)
        }
    }
    
    func save(endpoint: String) {
        store.set(endpoint, forKey: Key.endpoint)
        cache.set(endpoint, forKey: Key.endpoint)
        memory[Key.endpoint] = endpoint
    }
    
    func save(mode: String) {
        store.set(mode, forKey: Key.mode)
    }
    
    func markFirstLaunchDone() {
        store.set(true, forKey: Key.firstLaunch)
    }
    
    func save(notifications: NotificationConfig) {
        store.set(notifications.approved, forKey: Key.notifApproved)
        store.set(notifications.rejected, forKey: Key.notifRejected)
        
        if let date = notifications.lastRequest {
            store.set(date.timeIntervalSince1970 * 1000, forKey: Key.notifDate)
        }
    }
    
    func load() -> LoadedConfig {
        let endpoint = memory[Key.endpoint] as? String 
                    ?? store.string(forKey: Key.endpoint) 
                    ?? cache.string(forKey: Key.endpoint)
        
        let mode = store.string(forKey: Key.mode)
        let isFirstLaunch = !store.bool(forKey: Key.firstLaunch)
        
        var tracking: [String: String] = [:]
        if let json = memory[Key.tracking] as? String ?? store.string(forKey: Key.tracking),
           let dict = fromJSON(json) {
            tracking = dict
        }
        
        var navigation: [String: String] = [:]
        if let encoded = store.string(forKey: Key.navigation),
           let json = decode(encoded),
           let dict = fromJSON(json) {
            navigation = dict
        }
        
        let approved = store.bool(forKey: Key.notifApproved)
        let rejected = store.bool(forKey: Key.notifRejected)
        let ts = store.double(forKey: Key.notifDate)
        let date = ts > 0 ? Date(timeIntervalSince1970: ts / 1000) : nil
        
        let notifications = NotificationConfig(
            approved: approved,
            rejected: rejected,
            lastRequest: date
        )
        
        return LoadedConfig(
            endpoint: endpoint,
            mode: mode,
            isFirstLaunch: isFirstLaunch,
            tracking: tracking,
            navigation: navigation,
            notifications: notifications
        )
    }
    
    private func preload() {
        if let endpoint = store.string(forKey: Key.endpoint) {
            memory[Key.endpoint] = endpoint
        }
    }
    
    private func toJSON(_ dict: [String: String]) -> String? {
        let anyDict = dict.mapValues { $0 as Any }
        guard let data = try? JSONSerialization.data(withJSONObject: anyDict),
              let string = String(data: data, encoding: .utf8) else { return nil }
        return string
    }
    
    private func fromJSON(_ string: String) -> [String: String]? {
        guard let data = string.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        
        var result: [String: String] = [:]
        for (key, value) in dict {
            result[key] = "\(value)"
        }
        return result
    }
    
    private func encode(_ string: String) -> String {
        Data(string.utf8).base64EncodedString()
            .replacingOccurrences(of: "=", with: "|")
            .replacingOccurrences(of: "+", with: "~")
    }
    
    private func decode(_ string: String) -> String? {
        let base64 = string
            .replacingOccurrences(of: "|", with: "=")
            .replacingOccurrences(of: "~", with: "+")
        
        guard let data = Data(base64Encoded: base64),
              let str = String(data: data, encoding: .utf8) else { return nil }
        return str
    }
}

// UNIQUE: Validator
protocol Validator {
    func validate() async throws -> Bool
}

final class FirebaseValidator: Validator {
    func validate() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            Database.database().reference().child("users/log/data")
                .observeSingleEvent(of: .value) { snapshot in
                    if let url = snapshot.value as? String,
                       !url.isEmpty,
                       URL(string: url) != nil {
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                } withCancel: { error in
                    continuation.resume(throwing: error)
                }
        }
    }
}

protocol Backend {
    func fetchTracking(deviceID: String) async throws -> [String: Any]
    func fetchEndpoint(tracking: [String: Any]) async throws -> String
}

final class HTTPBackend: Backend {
    
    private let client: URLSession
    
    init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 90
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil
        
        self.client = URLSession(configuration: config)
    }
    
    func fetchTracking(deviceID: String) async throws -> [String: Any] {
        let base = "https://gcdsdk.appsflyer.com/install_data/v4.0"
        let app = "id\(Settings.appID)"
        
        var builder = URLComponents(string: "\(base)/\(app)")
        builder?.queryItems = [
            URLQueryItem(name: "devkey", value: Settings.devKey),
            URLQueryItem(name: "device_id", value: deviceID)
        ]
        
        guard let url = builder?.url else {
            throw BackendError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await client.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw BackendError.requestFailed
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw BackendError.decodingFailed
        }
        
        return json
    }
    
    private var userAgent: String = WKWebView().value(forKey: "userAgent") as? String ?? ""
    
    func fetchEndpoint(tracking: [String: Any]) async throws -> String {
        guard let url = URL(string: Settings.e) else {
            throw BackendError.invalidURL
        }
        
        var payload: [String: Any] = tracking
        payload["os"] = "iOS"
        payload["af_id"] = AppsFlyerLib.shared().getAppsFlyerUID()
        payload["bundle_id"] = Bundle.main.bundleIdentifier ?? ""
        payload["firebase_project_id"] = FirebaseApp.app()?.options.gcmSenderID
        payload["store_id"] = "id\(Settings.appID)"
        payload["push_token"] = UserDefaults.standard.string(forKey: "push_token") ?? Messaging.messaging().fcmToken
        payload["locale"] = Locale.preferredLanguages.first?.prefix(2).uppercased() ?? "EN"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        var lastError: Error?
        let retries: [Double] = [5.0, 10.0, 20.0]
        
        for (index, delay) in retries.enumerated() {
            do {
                let (data, response) = try await client.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw BackendError.requestFailed
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let success = json["ok"] as? Bool,
                          success,
                          let endpoint = json["url"] as? String else {
                        throw BackendError.decodingFailed
                    }
                    
                    return endpoint
                } else if httpResponse.statusCode == 429 {
                    let backoff = delay * Double(index + 1)
                    try await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
                    continue
                } else {
                    throw BackendError.requestFailed
                }
            } catch {
                lastError = error
                if index < retries.count - 1 {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? BackendError.requestFailed
    }
}

enum BackendError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}

