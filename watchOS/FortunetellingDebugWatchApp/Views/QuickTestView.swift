import SwiftUI

struct QuickTestView: View {
    @EnvironmentObject var connectivity: WatchConnectivity
    @State private var testResults: [String: TestResult] = [:]
    @State private var isRunning = false
    @State private var currentTestIndex = -1
    @State private var testStartTime: Date?
    @State private var totalTestTime: TimeInterval = 0
    
    let allTests = [
        ("四柱推命", "fourPillars"),
        ("西洋占星術", "westernAstrology"),
        ("数秘術", "numerology"),
        ("タロット", "tarot"),
        ("九星気学", "nineStarKi"),
        ("血液型", "bloodType"),
        ("六星占術", "rokusei")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // ヘッダー
                HStack {
                    Text("全APIテスト")
                        .font(.headline)
                    Spacer()
                    if isRunning {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                }
                
                // テストリスト
                ForEach(Array(allTests.enumerated()), id: \.offset) { index, test in
                    TestRow(
                        name: test.0,
                        result: testResults[test.0],
                        isCurrentTest: currentTestIndex == index
                    )
                }
                
                // コントロール
                VStack(spacing: 8) {
                    Button(action: runAllTests) {
                        if isRunning {
                            Label("実行中...", systemImage: "stop.circle")
                                .foregroundColor(.red)
                        } else {
                            Label("全テスト実行", systemImage: "play.circle.fill")
                        }
                    }
                    .disabled(!connectivity.isReachable)
                    
                    if !connectivity.isReachable {
                        Text("iPhone接続必要")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
                .padding(.top)
                
                // 結果サマリー
                if !testResults.isEmpty {
                    TestSummary(
                        results: testResults,
                        totalTime: totalTestTime
                    )
                }
            }
            .padding()
        }
        .navigationTitle("API診断")
        .onReceive(connectivity.$testResult) { result in
            handleTestResult(result)
        }
    }
    
    private func runAllTests() {
        guard !isRunning else {
            // 実行中なら停止
            stopTests()
            return
        }
        
        isRunning = true
        testResults = [:]
        currentTestIndex = 0
        testStartTime = Date()
        
        runNextTest()
    }
    
    private func runNextTest() {
        guard currentTestIndex < allTests.count else {
            completeAllTests()
            return
        }
        
        let test = allTests[currentTestIndex]
        connectivity.requestFortuneTest(type: test.1, birthDate: "1990-01-01")
        
        // タイムアウト処理
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.currentTestIndex < self.allTests.count &&
               self.testResults[test.0] == nil {
                self.testResults[test.0] = TestResult(
                    success: false,
                    message: "タイムアウト",
                    responseTime: 5.0
                )
                self.currentTestIndex += 1
                self.runNextTest()
            }
        }
    }
    
    private func handleTestResult(_ result: [String: Any]) {
        guard isRunning,
              currentTestIndex < allTests.count else { return }
        
        let test = allTests[currentTestIndex]
        let success = result["success"] as? Bool ?? false
        let message = result["message"] as? String ?? ""
        let responseTime = result["responseTime"] as? Double ?? 0
        
        testResults[test.0] = TestResult(
            success: success,
            message: message,
            responseTime: responseTime
        )
        
        currentTestIndex += 1
        
        // 次のテストを実行
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.runNextTest()
        }
    }
    
    private func completeAllTests() {
        isRunning = false
        currentTestIndex = -1
        if let startTime = testStartTime {
            totalTestTime = Date().timeIntervalSince(startTime)
        }
        
        // 振動フィードバック
        let allPassed = testResults.values.allSatisfy { $0.success }
        WKInterfaceDevice.current().play(allPassed ? .success : .notification)
    }
    
    private func stopTests() {
        isRunning = false
        currentTestIndex = -1
    }
}

struct TestResult {
    let success: Bool
    let message: String
    let responseTime: TimeInterval
}

struct TestRow: View {
    let name: String
    let result: TestResult?
    let isCurrentTest: Bool
    
    var body: some View {
        HStack {
            Text(name)
                .font(.caption)
                .foregroundColor(isCurrentTest ? .blue : .primary)
            
            Spacer()
            
            if isCurrentTest {
                ProgressView()
                    .scaleEffect(0.6)
            } else if let result = result {
                HStack(spacing: 4) {
                    Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(result.success ? .green : .red)
                        .font(.caption)
                    
                    Text("\(Int(result.responseTime * 1000))ms")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(
            isCurrentTest ? Color.blue.opacity(0.2) : Color.clear
        )
        .cornerRadius(6)
    }
}

struct TestSummary: View {
    let results: [String: TestResult]
    let totalTime: TimeInterval
    
    private var successCount: Int {
        results.values.filter { $0.success }.count
    }
    
    private var averageResponseTime: Double {
        let times = results.values.map { $0.responseTime }
        return times.isEmpty ? 0 : times.reduce(0, +) / Double(times.count)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("成功率")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(successCount)/\(results.count)")
                        .font(.caption)
                        .bold()
                        .foregroundColor(successCount == results.count ? .green : .orange)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("平均応答")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(Int(averageResponseTime * 1000))ms")
                        .font(.caption)
                        .bold()
                }
            }
            
            if totalTime > 0 {
                Text("総実行時間: \(String(format: "%.1f", totalTime))秒")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 8)
    }
}