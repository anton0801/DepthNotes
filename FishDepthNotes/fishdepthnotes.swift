
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
    static let appID = "6758788568"
    static let devKey = "j7QJUKCX7MZPey9Mb9pyxL"
    static let e = "https://deptthnotes.com/config.php"
}
