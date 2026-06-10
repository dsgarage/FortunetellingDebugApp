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
                
                Section("exia-api (Briefs)") {
                    TextField("exia-api URL", text: $settings.exiaAPIURL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Tailscale経由: 100.94.130.83:8000")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
        guard let url = URL(string: settings.fortuneTellingServerURL + "/api/health") else {
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
        settings.fortuneTellingServerURL = kDefaultFortuneServerURL
        settings.exiaAPIURL = kDefaultExiaAPIURL
        settings.clearAuth()
        alertMessage = "設定をリセットしました"
        showingAlert = true
    }
}