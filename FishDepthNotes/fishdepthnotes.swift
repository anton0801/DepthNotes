
import SwiftUI

@main
struct FishDepthNotesApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            DepthNotesSplashScreen()
        }
    }
}

struct Settings {
    static let appID = "6758240851"
    static let devKey = "oi7aE3fukWTyBKy6kHtXTF"
    static let e = "https://deptthnotes.com/config.php"
}
