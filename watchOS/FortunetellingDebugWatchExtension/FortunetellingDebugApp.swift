import SwiftUI

@main
struct FortunetellingDebugApp: App {
    @StateObject private var connectivity = WatchConnectivity()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivity)
        }
    }
}