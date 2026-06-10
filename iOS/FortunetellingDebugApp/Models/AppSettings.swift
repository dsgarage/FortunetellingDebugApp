import Foundation
import SwiftUI

/// 本番 API のデフォルト URL（Railway）。Issue #1。
let kDefaultFortuneServerURL = "https://fortunetelling-production-dd3e.up.railway.app"
/// exia-api（Briefs / 旧 exiaLogger）。FortuneTellingServer#419 で本体へ移植予定。
let kDefaultExiaAPIURL = "http://100.94.130.83:8000"

class AppSettings: ObservableObject {
    @Published var fortuneTellingServerURL: String {
        didSet {
            UserDefaults.standard.set(fortuneTellingServerURL, forKey: "fortuneTellingServerURL")
        }
    }

    @Published var exiaAPIURL: String {
        didSet {
            UserDefaults.standard.set(exiaAPIURL, forKey: "exiaAPIURL")
        }
    }

    // MARK: - 認証（JWT）

    /// アクセストークン（Bearer 用）。空ならログアウト状態。
    @Published var accessToken: String {
        didSet {
            UserDefaults.standard.set(accessToken, forKey: "accessToken")
        }
    }

    /// リフレッシュトークン。
    @Published var refreshToken: String {
        didSet {
            UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
        }
    }

    /// 直近ログインに使った email（再ログインの入力補助）。
    @Published var authEmail: String {
        didSet {
            UserDefaults.standard.set(authEmail, forKey: "authEmail")
        }
    }

    var isLoggedIn: Bool { !accessToken.isEmpty }

    // MARK: - X (Twitter) API

    @Published var xAPIKey: String {
        didSet { UserDefaults.standard.set(xAPIKey, forKey: "xAPIKey") }
    }

    @Published var xAPISecret: String {
        didSet { UserDefaults.standard.set(xAPISecret, forKey: "xAPISecret") }
    }

    @Published var xAccessToken: String {
        didSet { UserDefaults.standard.set(xAccessToken, forKey: "xAccessToken") }
    }

    @Published var xAccessTokenSecret: String {
        didSet { UserDefaults.standard.set(xAccessTokenSecret, forKey: "xAccessTokenSecret") }
    }

    init() {
        self.fortuneTellingServerURL =
            UserDefaults.standard.string(forKey: "fortuneTellingServerURL") ?? kDefaultFortuneServerURL
        self.exiaAPIURL =
            UserDefaults.standard.string(forKey: "exiaAPIURL") ?? kDefaultExiaAPIURL
        self.accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        self.refreshToken = UserDefaults.standard.string(forKey: "refreshToken") ?? ""
        self.authEmail = UserDefaults.standard.string(forKey: "authEmail") ?? ""
        self.xAPIKey = UserDefaults.standard.string(forKey: "xAPIKey") ?? ""
        self.xAPISecret = UserDefaults.standard.string(forKey: "xAPISecret") ?? ""
        self.xAccessToken = UserDefaults.standard.string(forKey: "xAccessToken") ?? ""
        self.xAccessTokenSecret = UserDefaults.standard.string(forKey: "xAccessTokenSecret") ?? ""
    }

    /// ログイン情報を破棄。
    func clearAuth() {
        accessToken = ""
        refreshToken = ""
    }
}
