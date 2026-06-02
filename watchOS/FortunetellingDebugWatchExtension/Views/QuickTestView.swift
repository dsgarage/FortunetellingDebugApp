import SwiftUI

struct QuickTestView: View {
    @EnvironmentObject var connectivity: WatchConnectivity
    @State private var testResults: [String: Bool] = [:]
    @State private var isRunning = false
    
    let allTests = [
        "四柱推命",
        "西洋占星術", 
        "数秘術",
        "タロット",
        "九星気学",
        "六星占術"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("全APIテスト")
                    .font(.headline)
                
                ForEach(allTests, id: \.self) { test in
                    HStack {
                        Text(test)
                            .font(.caption)
                        Spacer()
                        if let result = testResults[test] {
                            Image(systemName: result ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(result ? .green : .red)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Button(action: runAllTests) {
                    if isRunning {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("全テスト実行")
                    }
                }
                .disabled(isRunning || !connectivity.isReachable)
                .padding(.top)
                
                if !testResults.isEmpty {
                    let passed = testResults.values.filter { $0 }.count
                    let total = testResults.count
                    Text("\(passed)/\(total) 成功")
                        .font(.caption)
                        .foregroundColor(passed == total ? .green : .orange)
                }
            }
            .padding()
        }
    }
    
    private func runAllTests() {
        isRunning = true
        testResults = [:]
        
        for (index, test) in allTests.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                // シミュレーション: ランダムに成功/失敗
                testResults[test] = Bool.random()
                
                if index == allTests.count - 1 {
                    isRunning = false
                }
            }
        }
    }
}