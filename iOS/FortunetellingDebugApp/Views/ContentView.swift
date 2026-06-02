import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            APITestView()
                .tabItem {
                    Label("APIテスト", systemImage: "network")
                }
                .tag(0)
            
            XPostView()
                .tabItem {
                    Label("Xポスト", systemImage: "paperplane")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
                .tag(2)
        }
    }
}