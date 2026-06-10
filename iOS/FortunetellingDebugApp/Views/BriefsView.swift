import SwiftUI

struct BriefsView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var showingCreate = false
    @State private var editingBrief: Brief?
    @State private var editedText = ""
    @State private var selectedBrief: Brief?
    @State private var briefs: [Brief] = []
    @State private var stats: BriefStats?
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                // 統計情報
                if let stats = stats {
                    StatsCard(stats: stats)
                        .padding(.horizontal)
                }
                
                // Briefリスト
                if isLoading {
                    ProgressView("読み込み中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if briefs.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("未処理の案はありません ✨")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(briefs) { brief in
                                BriefCard(
                                    brief: brief,
                                    onApprove: { approveBrief(brief) },
                                    onEdit: { editBrief(brief) },
                                    onReject: { rejectBrief(brief) }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("エンゲージメント")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { Task { await refresh() } }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreate = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingCreate) {
                CreateBriefView(baseURL: settings.exiaAPIURL) {
                    showingCreate = false
                    Task { await refresh() }
                }
            }
            .sheet(item: $editingBrief) { brief in
                EditBriefView(
                    brief: brief,
                    editedText: $editedText,
                    onSave: { saveEditedBrief(brief) },
                    onCancel: { editingBrief = nil }
                )
            }
        }
        .onAppear {
            // APIのbaseURLを設定から初期化
            Task {
                await refresh()
            }
        }
    }
    
    private func refresh() async {
        let api = BriefAPI(baseURL: settings.exiaAPIURL)
        isLoading = true
        await api.fetchPendingBriefs()
        await api.fetchStats()
        briefs = api.briefs
        stats = api.stats
        isLoading = false
    }
    
    private func approveBrief(_ brief: Brief) {
        Task {
            do {
                let api = BriefAPI(baseURL: settings.exiaAPIURL)
                try await api.approveBrief(brief.id)
                await refresh()
            } catch {
                print("承認エラー: \(error)")
            }
        }
    }
    
    private func rejectBrief(_ brief: Brief) {
        Task {
            do {
                let api = BriefAPI(baseURL: settings.exiaAPIURL)
                try await api.rejectBrief(brief.id)
                await refresh()
            } catch {
                print("否認エラー: \(error)")
            }
        }
    }
    
    private func editBrief(_ brief: Brief) {
        editedText = brief.draftText
        editingBrief = brief
    }
    
    private func saveEditedBrief(_ brief: Brief) {
        Task {
            do {
                let api = BriefAPI(baseURL: settings.exiaAPIURL)
                try await api.editAndApproveBrief(brief.id, editedText: editedText)
                editingBrief = nil
                await refresh()
            } catch {
                print("編集保存エラー: \(error)")
            }
        }
    }
}

// Briefカード
struct BriefCard: View {
    let brief: Brief
    let onApprove: () -> Void
    let onEdit: () -> Void
    let onReject: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    
    var body: some View {
        ZStack {
            // 背景のヒント
            HStack {
                // 承認ヒント（右スワイプ）
                Text("承認 ✓")
                    .foregroundColor(.white)
                    .padding()
                    .opacity(offset > 50 ? Double(min(1, offset / 150)) : 0)
                Spacer()
                // 編集ヒント（左スワイプ）
                Text("編集")
                    .foregroundColor(.white)
                    .padding()
                    .opacity(offset < -50 ? Double(min(1, -offset / 150)) : 0)
            }
            .background(
                offset > 0 ? Color.green : Color.orange
            )
            
            // カード本体
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if !brief.targetHandle.isEmpty {
                        Label(brief.targetHandle, systemImage: "at")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(brief.topic)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Text(brief.displayText)
                    .font(.body)
                    .lineLimit(4)
                
                if let url = brief.targetURL {
                    Link(destination: url) {
                        Label("元投稿を開く", systemImage: "arrow.up.right.square")
                            .font(.caption)
                    }
                }
                
                // アクションボタン
                HStack {
                    Button(action: onEdit) {
                        Label("編集", systemImage: "pencil")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button(action: onReject) {
                        Label("否認", systemImage: "xmark")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    
                    Button(action: onApprove) {
                        Label("承認", systemImage: "checkmark")
                            .font(.caption)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .offset(x: offset)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    offset = value.translation.width
                }
                .onEnded { value in
                    isDragging = false
                    if offset > 150 {
                        // 右スワイプ = 承認
                        onApprove()
                    } else if offset < -150 {
                        // 左スワイプ = 編集
                        onEdit()
                    }
                    withAnimation {
                        offset = 0
                    }
                }
        )
    }
}

// 統計カード
struct StatsCard: View {
    let stats: BriefStats
    
    var body: some View {
        VStack(spacing: 8) {
            Text("エンゲージメント統計")
                .font(.headline)
            
            HStack(spacing: 20) {
                StatItem(title: "未処理", count: stats.counts.pending, color: .orange)
                StatItem(title: "承認済", count: stats.counts.approved, color: .blue)
                StatItem(title: "投稿済", count: stats.counts.posted, color: .green)
                StatItem(title: "否認", count: stats.counts.rejected, color: .red)
            }
            
            Text("今日の投稿: \(stats.postedToday)件")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct StatItem: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// Brief作成ビュー
struct CreateBriefView: View {
    let baseURL: String
    let onDismiss: () -> Void
    
    @State private var targetHandle = ""
    @State private var topic = ""
    @State private var draftText = ""
    @State private var targetUrl = ""
    @State private var isSubmitting = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("対象")) {
                    TextField("@ハンドル", text: $targetHandle)
                    TextField("元投稿URL", text: $targetUrl)
                }
                
                Section(header: Text("内容")) {
                    TextField("トピック", text: $topic)
                    TextEditor(text: $draftText)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("新規エンゲージメント")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("作成") {
                        createBrief()
                    }
                    .disabled(draftText.isEmpty || isSubmitting)
                }
            }
        }
    }
    
    private func createBrief() {
        isSubmitting = true
        Task {
            do {
                let api = BriefAPI(baseURL: baseURL)
                try await api.createBrief(
                    targetHandle: targetHandle,
                    topic: topic,
                    draftText: draftText,
                    targetUrl: targetUrl
                )
                await MainActor.run {
                    onDismiss()
                    dismiss()
                }
            } catch {
                print("作成エラー: \(error)")
                isSubmitting = false
            }
        }
    }
}

// Brief編集ビュー
struct EditBriefView: View {
    let brief: Brief
    @Binding var editedText: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("元の文章")) {
                        Text(brief.draftText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Section(header: Text("編集後の文章")) {
                        TextEditor(text: $editedText)
                            .frame(minHeight: 150)
                    }
                }
            }
            .navigationTitle("文章を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル", action: onCancel)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("承認して保存") {
                        onSave()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}