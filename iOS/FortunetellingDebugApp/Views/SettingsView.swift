import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("FortuneTelling Server") {
                    TextField("サーバーURL", text: $settings.fortuneTellingServerURL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("接続テスト") {
                        testConnection()
                    }
                }
                
                Section("X (Twitter) API認証") {
                    SecureField("API Key", text: $settings.xAPIKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("API Secret", text: $settings.xAPISecret)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Access Token", text: $settings.xAccessToken)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Access Token Secret", text: $settings.xAccessTokenSecret)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section("デバッグ情報") {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("ビルド")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("環境")
                        Spacer()
                        Text("Debug")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("設定をリセット") {
                        resetSettings()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("設定")
            .alert("通知", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func testConnection() {
        guard let url = URL(string: settings.fortuneTellingServerURL + "/health") else {
            alertMessage = "無効なURL"
            showingAlert = true
            return
        }
        
        Task {
            do {
                let (_, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse {
                    await MainActor.run {
                        if httpResponse.statusCode == 200 {
                            alertMessage = "接続成功"
                        } else {
                            alertMessage = "接続失敗: ステータスコード \(httpResponse.statusCode)"
                        }
                        showingAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    alertMessage = "接続エラー: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    private func resetSettings() {
        settings.fortuneTellingServerURL = "http://localhost:3000"
        settings.xAPIKey = ""
        settings.xAPISecret = ""
        settings.xAccessToken = ""
        settings.xAccessTokenSecret = ""
        alertMessage = "設定をリセットしました"
        showingAlert = true
    }
}