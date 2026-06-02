import Foundation
import WatchConnectivity
import WatchKit

class WatchConnectivity: NSObject, ObservableObject, WCSessionDelegate {
    @Published var lastResult: [String: Any] = [:]
    @Published var isReachable = false
    @Published var briefs: [Brief] = []
    @Published var briefStats: [String: Int] = [:]
    @Published var testResult: [String: Any] = [:]
    
    override init() {
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
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let action = message["action"] as? String {
                switch action {
                case "briefsResponse":
                    self.handleBriefsResponse(message)
                case "testResult":
                    self.testResult = message
                case "briefActionResponse":
                    self.handleBriefActionResponse(message)
                default:
                    self.lastResult = message
                }
            } else {
                self.lastResult = message
            }
        }
    }
    
    private func handleBriefsResponse(_ message: [String: Any]) {
        if let briefsData = message["briefs"] as? [[String: Any]] {
            self.briefs = briefsData.compactMap { dict in
                guard let id = dict["id"] as? Int,
                      let status = dict["status"] as? String,
                      let draftText = dict["draftText"] as? String else {
                    return nil
                }
                
                return Brief(
                    id: id,
                    status: status,
                    targetHandle: dict["targetHandle"] as? String ?? "",
                    topic: dict["topic"] as? String ?? "",
                    draftText: draftText,
                    targetUrl: dict["targetUrl"] as? String ?? "",
                    editedText: dict["editedText"] as? String
                )
            }
        }
        
        if let stats = message["stats"] as? [String: Int] {
            self.briefStats = stats
        }
    }
    
    private func handleBriefActionResponse(_ message: [String: Any]) {
        if let success = message["success"] as? Bool, success {
            WKInterfaceDevice.current().play(.success)
        }
    }
    
    func sendMessage(_ message: [String: Any]) {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending message: \(error)")
        }
    }
    
    func requestFortuneTest(type: String, birthDate: String? = nil) {
        var message: [String: Any] = ["action": "testFortune", "type": type]
        if let birthDate = birthDate {
            message["birthDate"] = birthDate
        }
        sendMessage(message)
    }
    
    func requestBriefs() {
        sendMessage(["action": "getBriefs"])
    }
    
    func sendBriefAction(briefId: Int, action: String) {
        sendMessage([
            "action": "briefAction",
            "briefId": briefId,
            "briefAction": action
        ])
    }