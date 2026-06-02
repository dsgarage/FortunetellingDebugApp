import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectivity: WatchConnectivity
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: APITestView()) {
                    Label("APIテスト", systemImage: "network")
                }
                
                NavigationLink(destination: QuickTestView()) {
                    Label("クイックテスト", systemImage: "bolt.fill")
                }
                
                NavigationLink(destination: ResultView()) {
                    Label("結果表示", systemImage: "doc.text")
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
            .navigationTitle("占いデバッグ")
        }
    }
}