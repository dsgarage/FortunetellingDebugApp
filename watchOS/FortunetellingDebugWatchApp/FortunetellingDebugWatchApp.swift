import SwiftUI

@main
struct FortunetellingDebugWatchApp: App {
    @StateObject private var connectivity = WatchConnectivity()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivity)
        }
    }
}