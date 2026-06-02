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
        default:
            break
        }
    }
    
    private func handleFortuneTest(message: [String: Any]) {
        guard let type = message["type"] as? String else { return }
        let birthDate = message["birthDate"] as? String ?? "1990-01-01"
        
        Task {
            do {
                var result: [String: Any] = [:]
                
                switch type {
                case "fourPillars":
                    let data = try await apiClient.testFourPillars(birthDate: birthDate)
                    result = ["type": data.fortuneType, "success": true]
                case "westernAstrology":
                    let data = try await apiClient.testWesternAstrology(birthDate: birthDate)
                    result = ["type": data.fortuneType, "success": true]
                case "numerology":
                    let data = try await apiClient.testNumerology(birthDate: birthDate)
                    result = ["type": data.fortuneType, "success": true]
                case "tarot":
                    let data = try await apiClient.testTarot()
                    result = ["type": data.fortuneType, "success": true]
                case "nineStarKi":
                    let data = try await apiClient.testNineStarKi(birthDate: birthDate)
                    result = ["type": data.fortuneType, "success": true]
                case "rokusei":
                    let data = try await apiClient.testRokusei(birthDate: birthDate)
                    result = ["type": data.fortuneType, "success": true]
                default:
                    result = ["error": "Unknown type"]
                }
                
                WCSession.default.sendMessage(result, replyHandler: nil)
            } catch {
                WCSession.default.sendMessage(["error": error.localizedDescription], replyHandler: nil)
            }
        }
    }
}