import SwiftUI

struct XPostView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var postContent = ""
    @State private var postType = "テン一天上"
    @State private var selectedDate = Date()
    @State private var isPosting = false
    @State private var postResult: String?
    @State private var errorMessage: String?
    @State private var characterCount = 0
    
    private let postTypes = [
        "テン一天上",
        "大殺界",
        "ボイドタイム",
        "運気カレンダー",
        "今月の運勢"
    ]
    
    private let templates: [String: String] = [
        "テン一天上": """
        【天一天上】開始のお知らせ ✨
        
        期間：MM月DD日〜MM月DD日
        
        天一天上とは、方位の神様が天に昇る16日間。
        この期間は全方位が吉となり、どの方角への移動も問題ありません。
        
        特に良いこと：
        ・旅行や引越し
        ・新しいことへの挑戦
        ・重要な決断
        
        #占い #天一天上 #暦 #開運
        """,
        
        "大殺界": """
        【六星占術】大殺界のお知らせ
        
        対象：◯◯星人（＋/−）
        期間：YYYY年MM月〜YYYY年MM月
        
        この期間は新しいことを始めず、
        現状維持を心がけましょう。
        
        避けるべきこと：
        ・転職や独立
        ・大きな投資
        ・新規事業の開始
        
        #六星占術 #大殺界 #占い
        """,
        
        "ボイドタイム": """
        【ボイドタイム情報】🌙
        
        日時：MM月DD日 HH:MM〜HH:MM
        継続時間：約◯時間
        
        この時間帯は重要な決断を避け、
        ゆったりと過ごすのがおすすめです。
        
        避けること：
        ・契約締結
        ・重要な会議
        ・新規プロジェクト開始
        
        #ボイドタイム #月齢 #占星術
        """,
        
        "運気カレンダー": """
        【今週の運気カレンダー】📅
        
        月曜：☆☆☆ 普通
        火曜：☆☆☆☆☆ 最高
        水曜：☆☆ 注意
        木曜：☆☆☆☆ 良好
        金曜：☆☆☆ 普通
        土曜：☆☆☆☆ 良好
        日曜：☆☆☆☆☆ 最高
        
        今週のラッキーデー：火曜・日曜
        要注意日：水曜
        
        #運気 #カレンダー #占い
        """,
        
        "今月の運勢": """
        【MM月の全体運】
        
        今月のテーマ：「◯◯」
        
        全体的な流れ：
        上旬：新しい出会いや機会
        中旬：決断の時期
        下旬：収穫と振り返り
        
        ラッキーアイテム：◯◯
        ラッキーカラー：◯◯色
        ラッキー方位：◯◯
        
        #月間占い #今月の運勢
        """
    ]
    
    private var remainingCharacters: Int {
        280 - postContent.count
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
            ZStack {
                // 背景グラデーション
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
                                    Text("FORTUNE")
                                        .font(.system(size: 14, weight: .black, design: .monospaced))
                                        .foregroundColor(CyberTheme.yellowAccent)
                                    Text("X POST")
                                        .font(.system(size: 24, weight: .black, design: .monospaced))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // 投稿タイプ選択
                        VStack(alignment: .leading, spacing: 16) {
                            Label {
                                Text("POST TYPE")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(CyberTheme.blackPrimary)
                            } icon: {
                                EmptyView()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(CyberTheme.yellowAccent)
                            .cornerRadius(4)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(postTypes, id: \.self) { type in
                                        Button(action: { 
                                            postType = type
                                            if let template = templates[type] {
                                                postContent = template
                                            }
                                        }) {
                                            Text(type)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(postType == type ? CyberTheme.blackPrimary : .white)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(postType == type ? CyberTheme.limeGreen : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .stroke(CyberTheme.limeGreen, lineWidth: 2)
                                                )
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 投稿内容編集
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("CONTENT")
                                    .font(.system(size: 14, weight: .black, design: .monospaced))
                                    .foregroundColor(CyberTheme.limeGreen)
                                Spacer()
                                Text("\(remainingCharacters)")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(characterCountColor)
                            }
                            
                            TextEditor(text: $postContent)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .scrollContentBackground(.hidden)
                                .background(Color.black.opacity(0.3))
                                .frame(minHeight: 200)
                                .padding(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(CyberTheme.limeGreen.opacity(0.5), lineWidth: 1)
                                )
                                .onChange(of: postContent) { _ in
                                    characterCount = postContent.count
                                }
                        }
                        .padding(.horizontal, 20)
                        
                        // 投稿ボタン
                        Button(action: postToServer) {
                            HStack(spacing: 12) {
                                if isPosting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: CyberTheme.blackPrimary))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 18))
                                }
                                Text("POST TO X")
                                    .font(.system(size: 16, weight: .black, design: .monospaced))
                                    .tracking(2)
                            }
                            .foregroundColor(CyberTheme.blackPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                ZStack {
                                    CyberTheme.yellowAccent
                                    if !isPosting {
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
                        .disabled(isPosting || postContent.isEmpty || remainingCharacters < 0)
                        .padding(.horizontal, 20)
                        
                        // 結果表示
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
                        
                        if let result = postResult {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(CyberTheme.limeGreen)
                                    Text("SUCCESS")
                                        .font(.system(size: 14, weight: .black, design: .monospaced))
                                        .foregroundColor(CyberTheme.limeGreen)
                                }
                                
                                Text(result)
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.green.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
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
        .onAppear {
            // 初期テンプレートをセット
            if let template = templates[postType] {
                postContent = template
            }
        }
    }
    
    private func postToServer() {
        isPosting = true
        errorMessage = nil
        postResult = nil
        
        // FortuneTellingサーバーの自動ポストAPIを使用
        guard let url = URL(string: "\(settings.fortuneTellingServerURL)/api/post/x") else {
            errorMessage = "無効なサーバーURL"
            isPosting = false
            return
        }
        
        Task {
            do {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let body = [
                    "content": postContent,
                    "type": postType,
                    "scheduled_at": ISO8601DateFormatter().string(from: selectedDate)
                ]
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let message = json["message"] as? String {
                            await MainActor.run {
                                self.postResult = message
                                self.postContent = ""
                                self.isPosting = false
                            }
                        } else {
                            await MainActor.run {
                                self.postResult = "投稿をキューに追加しました"
                                self.postContent = ""
                                self.isPosting = false
                            }
                        }
                    } else {
                        let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
                        await MainActor.run {
                            self.errorMessage = "エラー (\(httpResponse.statusCode)): \(errorText)"
                            self.isPosting = false
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isPosting = false
                }
            }
        }
    }
}