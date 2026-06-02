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
            Form {
                Section("テスト設定") {
                    Picker("占い種別", selection: $selectedFortuneType) {
                        ForEach(FortuneType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    if selectedFortuneType != .tarot {
                        DatePicker("生年月日", selection: $birthDate, displayedComponents: .date)
                    }
                    
                    if selectedFortuneType == .bloodType {
                        Picker("血液型", selection: $bloodType) {
                            ForEach(bloodTypes, id: \.self) { type in
                                Text(type + "型").tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                Section {
                    Button(action: testAPI) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "play.circle.fill")
                            }
                            Text("APIテスト実行")
                        }
                    }
                    .disabled(isLoading)
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                if let result = result {
                    Section("実行結果") {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(result.fortuneType, systemImage: "sparkles")
                                .font(.headline)
                            
                            Text("生年月日: \(result.birthDate)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("実行時刻: \(result.calculatedAt)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            ForEach(Array(result.result.keys).sorted(), id: \.self) { key in
                                HStack {
                                    Text(key)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(result.result[key] ?? "")")
                                        .font(.body)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("APIテスト")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showResult.toggle() }) {
                        Image(systemName: "doc.text.magnifyingglass")
                    }
                    .disabled(result == nil)
                }
            }
        }
        .sheet(isPresented: $showResult) {
            if let result = result {
                ResultDetailView(result: result)
            }
        }
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

struct ResultDetailView: View {
    let result: FortuneTellingResult
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(result.fortuneType)
                        .font(.largeTitle)
                        .bold()
                    
                    GroupBox("メタデータ") {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(result.birthDate, systemImage: "calendar")
                            Label(result.calculatedAt, systemImage: "clock")
                        }
                    }
                    
                    GroupBox("結果詳細") {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(result.result.keys).sorted(), id: \.self) { key in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(key)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(result.result[key] ?? "")")
                                        .font(.body)
                                }
                                Divider()
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("詳細結果")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}