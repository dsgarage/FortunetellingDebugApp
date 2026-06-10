import Foundation

// エンゲージメント管理用のBriefモデル
struct Brief: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let status: String
    let targetHandle: String
    let topic: String
    let draftText: String
    let targetUrl: String
    let editedText: String?
    
    enum CodingKeys: String, CodingKey {
        case id, status, topic
        case targetHandle = "target_handle"
        case draftText = "draft_text"
        case targetUrl = "target_url"
        case editedText = "edited_text"
    }
    
    // 表示用本文（編集済みがあればそれを優先）
    var displayText: String {
        if let e = editedText, !e.isEmpty { return e }
        return draftText
    }
    
    var targetURL: URL? {
        targetUrl.isEmpty ? nil : URL(string: targetUrl)
    }
}

// Brief統計情報
struct BriefStats: Codable, Equatable {
    struct Counts: Codable, Equatable {
        let pending: Int
        let approved: Int
        let posted: Int
        let rejected: Int
    }
    let counts: Counts
    let postedToday: Int
    let recentPosted: [PostedBrief]
    
    enum CodingKeys: String, CodingKey {
        case counts
        case postedToday = "posted_today"
        case recentPosted = "recent_posted"
    }
}

struct PostedBrief: Codable, Identifiable, Equatable {
    let id: Int
    let topic: String
    let text: String
    let tweetId: String?
    let postedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, topic, text
        case tweetId = "tweet_id"
        case postedAt = "posted_at"
    }
    
    var tweetURL: URL? {
        guard let t = tweetId, !t.isEmpty else { return nil }
        return URL(string: "https://x.com/hoshiiro_daily/status/\(t)")
    }
}

// Brief作成用のリクエスト
struct BriefRequest: Codable {
    let targetHandle: String
    let topic: String
    let draftText: String
    let targetUrl: String
    
    enum CodingKeys: String, CodingKey {
        case targetHandle = "target_handle"
        case topic
        case draftText = "draft_text"
        case targetUrl = "target_url"
    }
}

// Brief編集用のリクエスト
struct BriefEditRequest: Codable {
    let editedText: String
    
    enum CodingKeys: String, CodingKey {
        case editedText = "edited_text"
    }
}