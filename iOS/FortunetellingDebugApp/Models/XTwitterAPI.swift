import Foundation
import CryptoKit

class XTwitterAPI {
    private let apiKey: String
    private let apiSecret: String
    private let accessToken: String
    private let accessTokenSecret: String
    
    init(apiKey: String, apiSecret: String, accessToken: String, accessTokenSecret: String) {
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.accessToken = accessToken
        self.accessTokenSecret = accessTokenSecret
    }
    
    func postTweet(text: String) async throws -> [String: Any] {
        let url = URL(string: "https://api.twitter.com/2/tweets")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["text": text]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        // OAuth 1.0a署名を追加
        let oauthHeader = generateOAuthHeader(
            method: "POST",
            url: url.absoluteString,
            parameters: [:]
        )
        request.setValue(oauthHeader, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TwitterError.invalidResponse
        }
        
        if httpResponse.statusCode != 201 {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                throw TwitterError.apiError(errorData)
            }
            throw TwitterError.httpError(httpResponse.statusCode)
        }
        
        guard let result = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw TwitterError.invalidResponse
        }
        
        return result
    }
    
    private func generateOAuthHeader(method: String, url: String, parameters: [String: String]) -> String {
        var oauthParams: [String: String] = [
            "oauth_consumer_key": apiKey,
            "oauth_token": accessToken,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": "\(Int(Date().timeIntervalSince1970))",
            "oauth_nonce": UUID().uuidString,
            "oauth_version": "1.0"
        ]
        
        // 署名ベースストリングの作成
        var allParams = parameters
        for (key, value) in oauthParams {
            allParams[key] = value
        }
        
        let sortedParams = allParams.sorted { $0.key < $1.key }
        let paramString = sortedParams
            .map { "\(percentEncode($0.key))=\(percentEncode($0.value))" }
            .joined(separator: "&")
        
        let signatureBase = "\(method.uppercased())&\(percentEncode(url))&\(percentEncode(paramString))"
        
        // 署名キーの作成
        let signingKey = "\(percentEncode(apiSecret))&\(percentEncode(accessTokenSecret))"
        
        // HMAC-SHA1署名の生成
        let signature = hmacSHA1(key: signingKey, message: signatureBase)
        oauthParams["oauth_signature"] = signature
        
        // Authorizationヘッダーの作成
        let authHeader = "OAuth " + oauthParams
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\"\(percentEncode($0.value))\"" }
            .joined(separator: ", ")
        
        return authHeader
    }
    
    private func percentEncode(_ string: String) -> String {
        let allowedChars = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
        return string.addingPercentEncoding(withAllowedCharacters: allowedChars) ?? string
    }
    
    private func hmacSHA1(key: String, message: String) -> String {
        let keyData = key.data(using: .utf8)!
        let messageData = message.data(using: .utf8)!
        
        var hasher = HMAC<Insecure.SHA1>(key: SymmetricKey(data: keyData))
        hasher.update(data: messageData)
        let mac = hasher.finalize()
        
        return Data(mac).base64EncodedString()
    }
}

enum TwitterError: LocalizedError {
    case invalidResponse
    case httpError(Int)
    case apiError([String: Any])
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "無効なレスポンス"
        case .httpError(let code):
            return "HTTPエラー: \(code)"
        case .apiError(let error):
            return "APIエラー: \(error)"
        }
    }
}