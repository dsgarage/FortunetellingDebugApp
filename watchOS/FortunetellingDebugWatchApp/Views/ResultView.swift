import SwiftUI

struct ResultView: View {
    @EnvironmentObject var connectivity: WatchConnectivity
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("最新結果")
                    .font(.headline)
                
                if connectivity.lastResult.isEmpty {
                    Text("結果がありません")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                } else {
                    ForEach(Array(connectivity.lastResult.keys.sorted()), id: \.self) { key in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(key)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(connectivity.lastResult[key] ?? "")")
                                .font(.caption)
                                .lineLimit(2)
                        }
                        Divider()
                    }
                }
            }
            .padding()
        }
    }
}