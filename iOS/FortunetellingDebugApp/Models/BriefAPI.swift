import Foundation

class BriefAPI: ObservableObject {
    @Published var briefs: [Brief] = []
    @Published var stats: BriefStats?
    @Published var isLoading = false
    @Published var error: String?
    
    private let baseURL: String
    
    init(baseURL: String = "http://localhost:8000") {
        self.baseURL = baseURL
    }
    
    // 未処理のBriefを取得
    func fetchPendingBriefs() async {
        isLoading = true
        error = nil
        
        do {
            guard let url = URL(string: "\(baseURL)/briefs/pending") else {
                throw APIError.invalidURL
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let briefs = try JSONDecoder().decode([Brief].self, from: data)
            
            await MainActor.run {
                self.briefs = briefs
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // 統計情報を取得
    func fetchStats() async {
        do {
            guard let url = URL(string: "\(baseURL)/briefs/stats") else {
                throw APIError.invalidURL
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let stats = try JSONDecoder().decode(BriefStats.self, from: data)
            
            await MainActor.run {
                self.stats = stats
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }
    
    // Briefを承認
    func approveBrief(_ briefId: Int) async throws {
        guard let url = URL(string: "\(baseURL)/briefs/\(briefId)/approve") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
    }
    
    // Briefを否認
    func rejectBrief(_ briefId: Int) async throws {
        guard let url = URL(string: "\(baseURL)/briefs/\(briefId)/reject") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
    }
    
    // Briefを編集して承認
    func editAndApproveBrief(_ briefId: Int, editedText: String) async throws {
        guard let url = URL(string: "\(baseURL)/briefs/\(briefId)/edit") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let editRequest = BriefEditRequest(editedText: editedText)
        request.httpBody = try JSONEncoder().encode(editRequest)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
    }
    
    // 新しいBriefを作成
    func createBrief(targetHandle: String, topic: String, draftText: String, targetUrl: String) async throws {
        guard let url = URL(string: "\(baseURL)/briefs") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let briefRequest = BriefRequest(
            targetHandle: targetHandle,
            topic: topic,
            draftText: draftText,
            targetUrl: targetUrl
        )
        request.httpBody = try JSONEncoder().encode(briefRequest)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw APIError.serverError
        }
    }
    
    enum APIError: LocalizedError {
        case invalidURL
        case serverError
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "無効なURL"
            case .serverError:
                return "サーバーエラー"
            }
        }
    }
}