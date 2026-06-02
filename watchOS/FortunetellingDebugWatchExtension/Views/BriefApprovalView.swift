import SwiftUI

struct BriefApprovalView: View {
    @EnvironmentObject var connectivity: WatchConnectivity
    @State private var briefs: [Brief] = []
    @State private var isLoading = false
    @State private var pendingCount = 0
    @State private var todayApproved = 0
    @State private var showingDetail: Brief?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // ステータスヘッダー
                HStack(spacing: 16) {
                    VStack {
                        Text("\(pendingCount)")
                            .font(.title3)
                            .bold()
                        Text("承認待ち")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    VStack {
                        Text("\(todayApproved)")
                            .font(.title3)
                            .bold()
                        Text("今日承認")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                
                if isLoading {
                    ProgressView("読み込み中...")
                        .padding()
                } else if briefs.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                        Text("承認待ちなし")
                            .font(.caption)
                    }
                    .padding(.vertical, 20)
                } else {
                    ForEach(briefs) { brief in
                        BriefRow(brief: brief) { action in
                            handleAction(action, for: brief)
                        }
                    }
                }
                
                Button(action: loadBriefs) {
                    Label("更新", systemImage: "arrow.clockwise")
                        .font(.caption)
                }
                .disabled(isLoading)
                .padding(.top, 8)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("エンゲージ承認")
        .onAppear { loadBriefs() }
        .sheet(item: $showingDetail) { brief in
            BriefDetailView(brief: brief) { action in
                handleAction(action, for: brief)
            }
        }
    }
    
    private func loadBriefs() {
        isLoading = true
        connectivity.requestBriefs()
        
        // シミュレーション用のデータ
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.briefs = [
                Brief(id: 1, status: "pending", targetHandle: "@trend1", topic: "AI技術",
                      draftText: "最新のAI技術について解説します。", targetUrl: "", editedText: nil),
                Brief(id: 2, status: "pending", targetHandle: "", topic: "占い",
                      draftText: "今日の運勢をお届けします。", targetUrl: "", editedText: nil)
            ]
            self.pendingCount = 2
            self.todayApproved = 5
            self.isLoading = false
        }
    }
    
    private func handleAction(_ action: BriefAction, for brief: Brief) {
        connectivity.sendBriefAction(briefId: brief.id, action: action.rawValue)
        
        withAnimation {
            briefs.removeAll { $0.id == brief.id }
            pendingCount = briefs.count
            if action == .approve {
                todayApproved += 1
            }
        }
        
        // Haptic feedback
        WKInterfaceDevice.current().play(.success)
    }
}

enum BriefAction: String {
    case approve = "approve"
    case reject = "reject"
    case edit = "edit"
}

struct BriefRow: View {
    let brief: Brief
    let onAction: (BriefAction) -> Void
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    
    var body: some View {
        ZStack {
            // 背景アクション
            HStack {
                // 承認（右スワイプ）
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                
                // 否認（左スワイプ）
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
            }
            
            // コンテンツ
            VStack(alignment: .leading, spacing: 4) {
                if !brief.targetHandle.isEmpty {
                    Text(brief.targetHandle)
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .bold()
                }
                
                if !brief.topic.isEmpty {
                    Text(brief.topic)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(brief.shortText)
                    .font(.caption)
                    .lineLimit(2)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black)
            .cornerRadius(8)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        withAnimation(.interactiveSpring()) {
                            offset = value.translation.width
                            isDragging = true
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring()) {
                            if value.translation.width > 50 {
                                onAction(.approve)
                            } else if value.translation.width < -50 {
                                onAction(.reject)
                            }
                            offset = 0
                            isDragging = false
                        }
                    }
            )
        }
        .cornerRadius(8)
    }
}

struct BriefDetailView: View {
    let brief: Brief
    let onAction: (BriefAction) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if !brief.targetHandle.isEmpty {
                    Label(brief.targetHandle, systemImage: "at")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                if !brief.topic.isEmpty {
                    Label(brief.topic, systemImage: "tag")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(brief.displayText)
                    .font(.body)
                    .padding(.vertical, 8)
                
                VStack(spacing: 8) {
                    Button(action: {
                        onAction(.approve)
                        dismiss()
                    }) {
                        Label("承認", systemImage: "checkmark.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color.green)
                    .cornerRadius(8)
                    
                    Button(action: {
                        onAction(.reject)
                        dismiss()
                    }) {
                        Label("否認", systemImage: "xmark.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color.red)
                    .cornerRadius(8)
                    
                    Button(action: {
                        onAction(.edit)
                        dismiss()
                    }) {
                        Label("編集", systemImage: "pencil.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color.orange)
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}