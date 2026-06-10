import Foundation
import WatchConnectivity

class PhoneConnectivity: NSObject, ObservableObject, WCSessionDelegate {
    @Published var isReachable = false

    override init() {
        super.init()

        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    /// 現在の設定（URL + 保存済みトークン）でクライアントを生成する。
    private func makeClient() -> FortuneTellingAPI {
        let url = UserDefaults.standard.string(forKey: "fortuneTellingServerURL") ?? kDefaultFortuneServerURL
        let token = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        return FortuneTellingAPI(baseURL: url, accessToken: token)
    }

    /// Watch のクイックテスト種別を実エンドポイントへマッピングする。
    private func endpoint(for type: String, birthDate: String) -> (method: String, path: String, auth: Bool, body: [String: Any]?) {
        switch type {
        case "fourPillars":
            return ("GET", "/api/v1/fortune/bazi/meishiki", true, nil)
        case "westernAstrology":
            return ("GET", "/api/v1/fortune/horoscope", true, nil)
        case "rokusei":
            return ("POST", "/api/v1/fortune/rokusei/diagnose", true, ["birthdate": birthDate, "gender": "male"])
        case "numerology", "tarot", "nineStarKi", "bloodType":
            // 個別エンドポイントは無く、日運に統合されている
            return ("GET", "/api/v1/fortune/daily", true, nil)
        default:
            return ("GET", "/api/health", false, nil)
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
            let ep = endpoint(for: type, birthDate: birthDate)
            let resp = await makeClient().call(
                method: ep.method, path: ep.path, body: ep.body, auth: ep.auth
            )

            var message: String
            if resp.ok {
                message = "HTTP \(resp.statusCode) OK"
            } else if ep.auth && resp.statusCode == 401 {
                message = "HTTP 401 未ログイン（iPhone 側でログインしてください）"
            } else {
                message = "HTTP \(resp.statusCode)"
            }

            WCSession.default.sendMessage([
                "action": "testResult",
                "success": resp.ok,
                "message": message,
                "responseTime": Date().timeIntervalSince(startTime),
            ], replyHandler: nil)
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