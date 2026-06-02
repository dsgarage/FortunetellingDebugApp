import Foundation
import SwiftUI

class AppSettings: ObservableObject {
    @Published var fortuneTellingServerURL: String {
        didSet {
            UserDefaults.standard.set(fortuneTellingServerURL, forKey: "fortuneTellingServerURL")
        }
    }
    
    @Published var xAPIKey: String {
        didSet {
            UserDefaults.standard.set(xAPIKey, forKey: "xAPIKey")
        }
    }
    
    @Published var xAPISecret: String {
        didSet {
            UserDefaults.standard.set(xAPISecret, forKey: "xAPISecret")
        }
    }
    
    @Published var xAccessToken: String {
        didSet {
            UserDefaults.standard.set(xAccessToken, forKey: "xAccessToken")
        }
    }
    
    @Published var xAccessTokenSecret: String {
        didSet {
            UserDefaults.standard.set(xAccessTokenSecret, forKey: "xAccessTokenSecret")
        }
    }
    
    init() {
        self.fortuneTellingServerURL = UserDefaults.standard.string(forKey: "fortuneTellingServerURL") ?? "http://localhost:3000"
        self.xAPIKey = UserDefaults.standard.string(forKey: "xAPIKey") ?? ""
        self.xAPISecret = UserDefaults.standard.string(forKey: "xAPISecret") ?? ""
        self.xAccessToken = UserDefaults.standard.string(forKey: "xAccessToken") ?? ""
        self.xAccessTokenSecret = UserDefaults.standard.string(forKey: "xAccessTokenSecret") ?? ""
    }
}