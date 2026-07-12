import Foundation

/// API レスポンス（status コード + 整形済み本文）。
struct APIResponse {
    let statusCode: Int
    let body: String
    var ok: Bool { (200..<300).contains(statusCode) }
}

/// ログインで返るトークン対。
struct AuthTokens: Codable {
    let accessToken: String
    let refreshToken: String
}

/// テスト対象エンドポイント定義。Issue #1。
struct FortuneEndpoint: Identifiable {
    let id: Int
    let label: String
    let method: String
    let path: String
    let requiresAuth: Bool
    /// true の場合 `?date=YYYY-MM-DD` を付与する。
    let usesDateQuery: Bool
    /// POST ボディを組み立てる（引数 = 生年月日 YYYY-MM-DD）。nil なら body 無し。
    let bodyBuilder: ((String) -> [String: Any]?)?
}

/// 現行サーバー (/api/v1/*) を叩く汎用クライアント。Issue #1 で全面改修。
final class FortuneTellingAPI {
    let baseURL: String
    let accessToken: String?

    init(baseURL: String, accessToken: String? = nil) {
        self.baseURL = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
        self.accessToken = accessToken
    }

    /// ログインしてトークンを取得する。
    func login(email: String, password: String) async throws -> AuthTokens {
        let resp = await call(
            method: "POST",
            path: "/api/v1/auth/login",
            body: ["email": email, "password": password]
        )
        guard resp.ok else {
            throw NSError(
                domain: "Auth", code: resp.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "ログイン失敗 (HTTP \(resp.statusCode))\n\(resp.body)"]
            )
        }
        guard let data = resp.body.data(using: .utf8),
              let tokens = try? JSONDecoder().decode(AuthTokens.self, from: data) else {
            throw NSError(
                domain: "Auth", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "トークンの解析に失敗しました"]
            )
        }
        return tokens
    }

    /// エンドポイント定義を実行する。
    func execute(_ ep: FortuneEndpoint, birthdate: String) async -> APIResponse {
        var query: [String: String] = [:]
        if ep.usesDateQuery { query["date"] = birthdate }
        let body = ep.bodyBuilder?(birthdate)
        return await call(
            method: ep.method, path: ep.path,
            query: query, body: body, auth: ep.requiresAuth
        )
    }

    /// 低レベル呼び出し。status コードと整形済み本文を返す（例外は投げず本文に格納）。
    func call(
        method: String,
        path: String,
        query: [String: String] = [:],
        body: [String: Any]? = nil,
        auth: Bool = false
    ) async -> APIResponse {
        var comps = URLComponents(string: baseURL + path)
        if !query.isEmpty {
            comps?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = comps?.url else {
            return APIResponse(statusCode: -1, body: "無効なURL: \(baseURL + path)")
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        if auth, let token = accessToken, !token.isEmpty {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            return APIResponse(statusCode: code, body: Self.pretty(data))
        } catch {
            return APIResponse(statusCode: -1, body: "通信エラー: \(error.localizedDescription)")
        }
    }

    /// JSON を整形（非 JSON は生文字列のまま）。
    static func pretty(_ data: Data) -> String {
        if data.isEmpty { return "(空レスポンス)" }
        if let obj = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(
               withJSONObject: obj, options: [.prettyPrinted, .withoutEscapingSlashes]),
           let s = String(data: prettyData, encoding: .utf8) {
            return s
        }
        return String(data: data, encoding: .utf8) ?? "(デコード不可)"
    }
}

/// テスト対象エンドポイントのカタログ（現行 OpenAPI /api/docs-json 準拠）。
enum FortuneCatalog {
    static let endpoints: [FortuneEndpoint] = [
        // --- 公開 ---
        FortuneEndpoint(id: 0, label: "health (公開)", method: "GET",
                        path: "/api/health", requiresAuth: false, usesDateQuery: false, bodyBuilder: nil),
        FortuneEndpoint(id: 1, label: "今日のコラム (公開)", method: "GET",
                        path: "/api/v1/fortune/daily-column/today", requiresAuth: false, usesDateQuery: false, bodyBuilder: nil),
        FortuneEndpoint(id: 2, label: "codex 一覧 (公開)", method: "GET",
                        path: "/fortune-content/codexes", requiresAuth: false, usesDateQuery: false, bodyBuilder: nil),
        // --- 認証 GET ---
        FortuneEndpoint(id: 3, label: "ユーザー情報 me", method: "GET",
                        path: "/api/v1/users/me", requiresAuth: true, usesDateQuery: false, bodyBuilder: nil),
        FortuneEndpoint(id: 4, label: "日運 daily", method: "GET",
                        path: "/api/v1/fortune/daily", requiresAuth: true, usesDateQuery: true, bodyBuilder: nil),
        FortuneEndpoint(id: 5, label: "週運 weekly", method: "GET",
                        path: "/api/v1/fortune/weekly", requiresAuth: true, usesDateQuery: false, bodyBuilder: nil),
        FortuneEndpoint(id: 6, label: "月運 monthly", method: "GET",
                        path: "/api/v1/fortune/monthly", requiresAuth: true, usesDateQuery: false, bodyBuilder: nil),
        FortuneEndpoint(id: 7, label: "ランキング ranking", method: "GET",
                        path: "/api/v1/fortune/ranking", requiresAuth: true, usesDateQuery: false, bodyBuilder: nil),
        FortuneEndpoint(id: 8, label: "予報 forecast", method: "GET",
                        path: "/api/v1/fortune/forecast", requiresAuth: true, usesDateQuery: false, bodyBuilder: nil),
        FortuneEndpoint(id: 9, label: "ホロスコープ horoscope", method: "GET",
                        path: "/api/v1/fortune/horoscope", requiresAuth: true, usesDateQuery: false, bodyBuilder: nil),
        FortuneEndpoint(id: 10, label: "命式 bazi/meishiki", method: "GET",
                        path: "/api/v1/fortune/bazi/meishiki", requiresAuth: true, usesDateQuery: false, bodyBuilder: nil),
        FortuneEndpoint(id: 11, label: "大運 bazi/taiun", method: "GET",
                        path: "/api/v1/fortune/bazi/taiun", requiresAuth: true, usesDateQuery: false, bodyBuilder: nil),
        FortuneEndpoint(id: 12, label: "人生フェーズ life-phases", method: "GET",
                        path: "/api/v1/fortune/life-phases", requiresAuth: true, usesDateQuery: false, bodyBuilder: nil),
        FortuneEndpoint(id: 13, label: "年間予報 year-forecast", method: "GET",
                        path: "/api/v1/fortune/year-forecast", requiresAuth: true, usesDateQuery: false, bodyBuilder: nil),
        FortuneEndpoint(id: 14, label: "カテゴリ予報 category-forecast", method: "GET",
                        path: "/api/v1/fortune/category-forecast", requiresAuth: true, usesDateQuery: false, bodyBuilder: nil),
        FortuneEndpoint(id: 15, label: "恋愛詳細 love-detail", method: "GET",
                        path: "/api/v1/fortune/daily/love-detail", requiresAuth: true, usesDateQuery: false, bodyBuilder: nil),
        // --- 認証 POST (diagnose) ---
        FortuneEndpoint(id: 16, label: "六星占術 rokusei/diagnose", method: "POST",
                        path: "/api/v1/fortune/rokusei/diagnose", requiresAuth: true, usesDateQuery: false,
                        bodyBuilder: { d in ["birthdate": d, "gender": "male"] }),
        FortuneEndpoint(id: 17, label: "姓名判断 seimei/diagnose", method: "POST",
                        path: "/api/v1/fortune/seimei/diagnose", requiresAuth: true, usesDateQuery: false,
                        bodyBuilder: { _ in ["tenkaku": 18, "jinkaku": 23, "chikaku": 14, "sokaku": 32, "gokaku": 39] }),
        FortuneEndpoint(id: 18, label: "四柱推命テーマ bazi/diagnose-themed", method: "POST",
                        path: "/api/v1/fortune/bazi/diagnose-themed", requiresAuth: true, usesDateQuery: false,
                        bodyBuilder: { d in ["birthdate": d, "birthTime": "12:00", "theme": "career"] }),
    ]
}
