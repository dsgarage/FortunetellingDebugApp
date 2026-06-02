import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectivity: WatchConnectivity
    
    var body: some View {
        NavigationView {
            List {
                Section("エンゲージ") {
                    NavigationLink(destination: BriefApprovalView()) {
                        HStack {
                            Label("承認管理", systemImage: "checkmark.seal")
                            if !connectivity.briefs.isEmpty {
                                Spacer()
                                Text("\(connectivity.briefs.count)")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                
                Section("APIテスト") {
                    NavigationLink(destination: QuickTestView()) {
                        Label("全API診断", systemImage: "bolt.fill")
                    }
                    
                    NavigationLink(destination: APITestView()) {
                        Label("個別テスト", systemImage: "network")
                    }
                    
                    NavigationLink(destination: ResultView()) {
                        Label("結果詳細", systemImage: "doc.text")
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: connectivity.isReachable ? "applewatch.radiowaves.left.and.right" : "applewatch.slash")
                            .foregroundColor(connectivity.isReachable ? .green : .red)
                        Text(connectivity.isReachable ? "iPhone接続中" : "iPhone未接続")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("デバッグ")
        }
    }
}