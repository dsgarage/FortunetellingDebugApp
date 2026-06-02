import Foundation
import WatchConnectivity

class WatchConnectivity: NSObject, ObservableObject, WCSessionDelegate {
    @Published var lastResult: [String: Any] = [:]
    @Published var isReachable = false
    
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
            self.lastResult = message
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
}