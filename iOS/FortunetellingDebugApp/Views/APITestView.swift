import SwiftUI

struct APITestView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var birthDate = Date()
    @State private var bloodType = "A"
    @State private var selectedFortuneType = FortuneType.fourPillars
    @State private var isLoading = false
    @State private var result: FortuneTellingResult?
    @State private var errorMessage: String?
    @State private var showResult = false
    
    private let bloodTypes = ["A", "B", "O", "AB"]
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景グラデーション（サイバーマンデー風）
                LinearGradient(
                    gradient: Gradient(colors: [CyberTheme.blackPrimary, Color.black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // ヘッダー
                        VStack(spacing: 8) {
                            HStack(spacing: 12) {
                                Rectangle()
                                    .fill(CyberTheme.yellowAccent)
                                    .frame(width: 4, height: 40)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("CYBER")
                                        .font(.system(size: 14, weight: .black, design: .monospaced))
                                        .foregroundColor(CyberTheme.yellowAccent)
                                    Text("API TEST")
                                        .font(.system(size: 24, weight: .black, design: .monospaced))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            
                            // 斜線パターン
                            GeometryReader { geometry in
                                Path { path in
                                    let width = geometry.size.width
                                    let height: CGFloat = 4
                                    let stripeWidth: CGFloat = 8
                                    
                                    for i in stride(from: -height, to: width + height, by: stripeWidth * 2) {
                                        path.move(to: CGPoint(x: i, y: 0))
                                        path.addLine(to: CGPoint(x: i + stripeWidth, y: height))
                                    }
                                }
                                .stroke(CyberTheme.yellowAccent.opacity(0.3), lineWidth: 2)
                            }
                            .frame(height: 4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // テスト設定セクション
                        VStack(alignment: .leading, spacing: 16) {
                            Label {
                                Text("SERVICE")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(CyberTheme.blackPrimary)
                            } icon: {
                                EmptyView()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(CyberTheme.yellowAccent)
                            .cornerRadius(4)
                            
                            VStack(spacing: 16) {
                                // 占い種別選択
                                HStack {
                                    Text("占い種別")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                    Spacer()
                                    Menu {
                                        ForEach(FortuneType.allCases, id: \.self) { type in
                                            Button(action: { selectedFortuneType = type }) {
                                                Text(type.rawValue)
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(selectedFortuneType.rawValue)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(CyberTheme.blackPrimary)
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12))
                                                .foregroundColor(CyberTheme.blackPrimary)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(CyberTheme.limeGreen)
                                        .cornerRadius(6)
                                    }
                                }
                                
                                // 生年月日
                                if selectedFortuneType != .tarot {
                                    HStack {
                                        Text("生年月日")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                        Spacer()
                                        DatePicker("", selection: $birthDate, displayedComponents: .date)
                                            .datePickerStyle(CompactDatePickerStyle())
                                            .accentColor(CyberTheme.yellowAccent)
                                            .colorScheme(.dark)
                                    }
                                }
                                
                                // 血液型
                                if selectedFortuneType == .bloodType {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("血液型")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                        HStack(spacing: 8) {
                                            ForEach(bloodTypes, id: \.self) { type in
                                                Button(action: { bloodType = type }) {
                                                    Text(type + "型")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(bloodType == type ? CyberTheme.blackPrimary : .white)
                                                        .frame(maxWidth: .infinity, minHeight: 40)
                                                        .background(
                                                            bloodType == type ? CyberTheme.yellowAccent : Color.clear
                                                        )
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 6)
                                                                .stroke(CyberTheme.yellowAccent, lineWidth: 2)
                                                        )
                                                        .cornerRadius(6)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(CyberTheme.darkGray.opacity(0.5))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(
                                                style: StrokeStyle(lineWidth: 1, dash: [5, 3])
                                            )
                                            .foregroundColor(CyberTheme.yellowAccent.opacity(0.5))
                                    )
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // 実行ボタン
                        Button(action: testAPI) {
                            HStack(spacing: 12) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: CyberTheme.blackPrimary))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 18))
                                }
                                Text("EXECUTE TEST")
                                    .font(.system(size: 16, weight: .black, design: .monospaced))
                                    .tracking(2)
                            }
                            .foregroundColor(CyberTheme.blackPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                ZStack {
                                    CyberTheme.yellowAccent
                                    if !isLoading {
                                        GeometryReader { geometry in
                                            Path { path in
                                                let width = geometry.size.width
                                                let height = geometry.size.height
                                                let stripeWidth: CGFloat = 10
                                                
                                                for i in stride(from: -height, to: width + height, by: stripeWidth * 2) {
                                                    path.move(to: CGPoint(x: i, y: 0))
                                                    path.addLine(to: CGPoint(x: i + height, y: height))
                                                }
                                            }
                                            .stroke(CyberTheme.blackPrimary.opacity(0.1), lineWidth: 4)
                                        }
                                    }
                                }
                            )
                            .cornerRadius(8)
                        }
                        .disabled(isLoading)
                        .padding(.horizontal, 20)
                        
                        // エラー表示
                        if let error = errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.red)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.red.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // 実行結果
                        if let result = result {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Rectangle()
                                        .fill(CyberTheme.limeGreen)
                                        .frame(width: 4, height: 20)
                                    Text("RESULT")
                                        .font(.system(size: 14, weight: .black, design: .monospaced))
                                        .foregroundColor(CyberTheme.limeGreen)
                                    Spacer()
                                    Text(result.fortuneType)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(CyberTheme.blackPrimary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(CyberTheme.limeGreen)
                                        .cornerRadius(4)
                                }
                                
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("生年月日")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.5))
                                        Spacer()
                                        Text(result.birthDate)
                                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                                            .foregroundColor(CyberTheme.limeGreen)
                                    }
                                    
                                    HStack {
                                        Text("実行時刻")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.5))
                                        Spacer()
                                        Text(result.calculatedAt)
                                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                                            .foregroundColor(CyberTheme.limeGreen)
                                    }
                                    
                                    Rectangle()
                                        .fill(CyberTheme.limeGreen.opacity(0.2))
                                        .frame(height: 1)
                                    
                                    ForEach(Array(result.result.keys).sorted(), id: \.self) { key in
                                        HStack {
                                            Text(key)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.white.opacity(0.7))
                                            Spacer()
                                            if let value = result.result[key] {
                                                Text("\(value)")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.black.opacity(0.5))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(CyberTheme.limeGreen.opacity(0.5), lineWidth: 1)
                                        )
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }
    
    private func testAPI() {
        isLoading = true
        errorMessage = nil
        result = nil
        
        let api = FortuneTellingAPI(baseURL: settings.fortuneTellingServerURL)
        let birthDateString = dateFormatter.string(from: birthDate)
        
        Task {
            do {
                let testResult: FortuneTellingResult
                
                switch selectedFortuneType {
                case .fourPillars:
                    testResult = try await api.testFourPillars(birthDate: birthDateString)
                case .westernAstrology:
                    testResult = try await api.testWesternAstrology(birthDate: birthDateString)
                case .numerology:
                    testResult = try await api.testNumerology(birthDate: birthDateString)
                case .tarot:
                    testResult = try await api.testTarot()
                case .nineStarKi:
                    testResult = try await api.testNineStarKi(birthDate: birthDateString)
                case .bloodType:
                    testResult = try await api.testBloodType(bloodType: bloodType)
                case .rokusei:
                    testResult = try await api.testRokusei(birthDate: birthDateString)
                }
                
                await MainActor.run {
                    self.result = testResult
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}