import Foundation
import WatchConnectivity

class PhoneConnectivity: NSObject, ObservableObject, WCSessionDelegate {
    @Published var isReachable = false
    private let apiClient: FortuneTellingAPI
    
    override init() {
        self.apiClient = FortuneTellingAPI(baseURL: UserDefaults.standard.string(forKey: "fortuneTellingServerURL") ?? "http://localhost:3000")
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let action = message["action"] as? String else { return }
        
        switch action {
        case "testFortune":
            handleFortuneTest(message: message)
        case "getBriefs":
            handleGetBriefs()
        case "briefAction":
            handleBriefAction(message: message)
        default:
            break
        }
    }
    
    private func handleFortuneTest(message: [String: Any]) {
        guard let type = message["type"] as? String else { return }
        let birthDate = message["birthDate"] as? String ?? "1990-01-01"
        let startTime = Date()
        
        Task {
            do {
                var result: [String: Any] = ["action": "testResult"]
                
                switch type {
                case "fourPillars":
                    let data = try await apiClient.testFourPillars(birthDate: birthDate)
                    result["success"] = true
                    result["message"] = data.fortuneType
                case "westernAstrology":
                    let data = try await apiClient.testWesternAstrology(birthDate: birthDate)
                    result["success"] = true
                    result["message"] = data.fortuneType
                case "numerology":
                    let data = try await apiClient.testNumerology(birthDate: birthDate)
                    result["success"] = true
                    result["message"] = data.fortuneType
                case "tarot":
                    let data = try await apiClient.testTarot()
                    result["success"] = true
                    result["message"] = data.fortuneType
                case "nineStarKi":
                    let data = try await apiClient.testNineStarKi(birthDate: birthDate)
                    result["success"] = true
                    result["message"] = data.fortuneType
                case "bloodType":
                    let data = try await apiClient.testBloodType(bloodType: "A")
                    result["success"] = true
                    result["message"] = data.fortuneType
                case "rokusei":
                    let data = try await apiClient.testRokusei(birthDate: birthDate)
                    result["success"] = true
                    result["message"] = data.fortuneType
                default:
                    result["success"] = false
                    result["message"] = "Unknown type"
                }
                
                result["responseTime"] = Date().timeIntervalSince(startTime)
                WCSession.default.sendMessage(result, replyHandler: nil)
            } catch {
                WCSession.default.sendMessage([
                    "action": "testResult",
                    "success": false,
                    "message": error.localizedDescription,
                    "responseTime": Date().timeIntervalSince(startTime)
                ], replyHandler: nil)
            }
        }
    }
    
    private func handleGetBriefs() {
        // シミュレーションデータを送信
        let response: [String: Any] = [
            "action": "briefsResponse",
            "briefs": [
                [
                    "id": 1,
                    "status": "pending",
                    "targetHandle": "@tech_trend",
                    "topic": "AI最新技術",
                    "draftText": "ChatGPTの新機能について解説。音声認識とリアルタイム翻訳が大幅に改善されました。",
                    "targetUrl": "https://example.com/1"
                ],
                [
                    "id": 2,
                    "status": "pending",
                    "targetHandle": "",
                    "topic": "今日の占い",
                    "draftText": "本日の運勢：牡羊座は新しいチャレンジに最適な日。積極的に行動しましょう。",
                    "targetUrl": ""
                ],
                [
                    "id": 3,
                    "status": "pending",
                    "targetHandle": "@news_jp",
                    "topic": "速報",
                    "draftText": "東京で新しいテクノロジーイベントが開催決定。参加登録受付中。",
                    "targetUrl": "https://example.com/3"
                ]
            ],
            "stats": [
                "pending": 3,
                "todayApproved": 7
            ]
        ]
        
        WCSession.default.sendMessage(response, replyHandler: nil)
    }
    
    private func handleBriefAction(message: [String: Any]) {
        guard let briefId = message["briefId"] as? Int,
              let action = message["briefAction"] as? String else { return }
        
        // 実際のAPIコール代わりのシミュレーション
        print("Brief action: \(action) for ID: \(briefId)")
        
        // 成功レスポンスを返す
        WCSession.default.sendMessage([
            "action": "briefActionResponse",
            "success": true,
            "briefId": briefId,
            "briefAction": action
        ], replyHandler: nil)
    }
}