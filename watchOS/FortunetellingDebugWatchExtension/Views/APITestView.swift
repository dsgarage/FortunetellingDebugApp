import SwiftUI

struct APITestView: View {
    @EnvironmentObject var connectivity: WatchConnectivity
    @State private var selectedTest = 0
    @State private var isLoading = false
    
    let testTypes = [
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
                Text("APIテスト")
                    .font(.headline)
                
                Picker("占い種別", selection: $selectedTest) {
                    ForEach(0..<testTypes.count, id: \.self) { index in
                        Text(testTypes[index].0).tag(index)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 50)
                
                Button(action: runTest) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("テスト実行")
                    }
                }
                .disabled(isLoading || !connectivity.isReachable)
                
                if !connectivity.isReachable {
                    Text("iPhone接続が必要です")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
    }
    
    private func runTest() {
        isLoading = true
        let testType = testTypes[selectedTest].1
        connectivity.requestFortuneTest(type: testType, birthDate: "1990-01-01")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
        }
    }
}