import SwiftUI

struct XPostView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var tweetText = ""
    @State private var isPosting = false
    @State private var postResult: String?
    @State private var errorMessage: String?
    @State private var characterCount = 0
    @State private var templates = [
        "今日の占い結果をお届けします🔮",
        "【四柱推命】本日の運勢",
        "【数秘術】あなたの運命数は",
        "【九星気学】今月の方位",
        "【タロット】今日のメッセージ"
    ]
    @State private var selectedTemplate = 0
    
    private var remainingCharacters: Int {
        280 - tweetText.count
    }
    
    private var characterCountColor: Color {
        if remainingCharacters < 0 {
            return .red
        } else if remainingCharacters < 20 {
            return .orange
        } else {
            return .secondary
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("テンプレート") {
                    Picker("テンプレート選択", selection: $selectedTemplate) {
                        ForEach(0..<templates.count, id: \.self) { index in
                            Text(templates[index]).tag(index)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                    
                    Button("テンプレートを適用") {
                        tweetText = templates[selectedTemplate]
                    }
                }
                
                Section("投稿内容") {
                    TextEditor(text: $tweetText)
                        .frame(minHeight: 150)
                        .onChange(of: tweetText) { _ in
                            characterCount = tweetText.count
                        }
                    
                    HStack {
                        Text("文字数: \(tweetText.count)")
                            .font(.caption)
                        Spacer()
                        Text("残り: \(remainingCharacters)")
                            .font(.caption)
                            .foregroundColor(characterCountColor)
                    }
                }
                
                Section {
                    Button(action: postToX) {
                        HStack {
                            if isPosting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "paperplane.fill")
                            }
                            Text("Xに投稿")
                        }
                    }
                    .disabled(isPosting || tweetText.isEmpty || remainingCharacters < 0)
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    if let result = postResult {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("投稿成功", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(result)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("最近の投稿") {
                    ForEach(0..<3) { index in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("投稿 #\(index + 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("サンプル投稿テキスト...")
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Xポスト")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: clearForm) {
                        Image(systemName: "trash")
                    }
                    .disabled(tweetText.isEmpty)
                }
            }
        }
    }
    
    private func postToX() {
        guard !settings.xAPIKey.isEmpty,
              !settings.xAPISecret.isEmpty,
              !settings.xAccessToken.isEmpty,
              !settings.xAccessTokenSecret.isEmpty else {
            errorMessage = "X APIの認証情報を設定してください"
            return
        }
        
        isPosting = true
        errorMessage = nil
        postResult = nil
        
        let api = XTwitterAPI(
            apiKey: settings.xAPIKey,
            apiSecret: settings.xAPISecret,
            accessToken: settings.xAccessToken,
            accessTokenSecret: settings.xAccessTokenSecret
        )
        
        Task {
            do {
                let result = try await api.postTweet(text: tweetText)
                await MainActor.run {
                    if let data = result["data"] as? [String: Any],
                       let id = data["id"] as? String {
                        self.postResult = "投稿ID: \(id)"
                        self.tweetText = ""
                    }
                    self.isPosting = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isPosting = false
                }
            }
        }
    }
    
    private func clearForm() {
        tweetText = ""
        postResult = nil
        errorMessage = nil
    }
}