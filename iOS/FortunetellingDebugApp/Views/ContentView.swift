import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var selectedTab = 0
    
    init() {
        // TabViewの外観をカスタマイズ
        UITabBar.appearance().backgroundColor = UIColor(CyberTheme.blackPrimary)
        UITabBar.appearance().unselectedItemTintColor = UIColor(CyberTheme.darkGray)
        UITabBar.appearance().tintColor = UIColor(CyberTheme.yellowAccent)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            APITestView()
                .tabItem {
                    Label("APIテスト", systemImage: "network")
                }
                .tag(0)
            
            BriefsView()
                .tabItem {
                    Label("エンゲージ", systemImage: "text.bubble")
                }
                .tag(1)
            
            XPostView()
                .tabItem {
                    Label("Xポスト", systemImage: "paperplane")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
                .tag(3)
        }
        .accentColor(CyberTheme.yellowAccent)
    }
}