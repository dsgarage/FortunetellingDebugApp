import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectivity: WatchConnectivity
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // エンゲージメント承認画面
            BriefApprovalView()
                .tag(0)
            
            // APIテスト画面
            QuickTestView()
                .tag(1)
            
            // 統計画面
            StatsView()
                .tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

struct StatsView: View {
    @EnvironmentObject var connectivity: WatchConnectivity
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("統計")
                    .font(.headline)
                
                if !connectivity.briefStats.isEmpty {
                    HStack {
                        StatItem(title: "未処理", value: connectivity.briefStats["pending"] ?? 0, color: .orange)
                        StatItem(title: "承認", value: connectivity.briefStats["approved"] ?? 0, color: .green)
                    }
                    
                    HStack {
                        StatItem(title: "投稿", value: connectivity.briefStats["posted"] ?? 0, color: .blue)
                        StatItem(title: "否認", value: connectivity.briefStats["rejected"] ?? 0, color: .red)
                    }
                }
                
                Text("接続: \(connectivity.isReachable ? "✅" : "❌")")
                    .font(.caption)
                    .padding(.top)
            }
            .padding()
        }
    }
}

struct StatItem: View {
    let title: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack {
            Text("\(value)")
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.caption2)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}