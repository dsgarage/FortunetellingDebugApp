import Foundation

struct FortuneTellingResult: Codable {
    let fortuneType: String
    let result: [String: Any]
    let birthDate: String
    let calculatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case fortuneType
        case result
        case birthDate
        case calculatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fortuneType = try container.decode(String.self, forKey: .fortuneType)
        birthDate = try container.decode(String.self, forKey: .birthDate)
        calculatedAt = try container.decode(String.self, forKey: .calculatedAt)
        
        if let resultData = try? container.decode([String: String].self, forKey: .result) {
            result = resultData
        } else if let resultData = try? container.decode([String: Int].self, forKey: .result) {
            result = resultData
        } else {
            result = [:]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fortuneType, forKey: .fortuneType)
        try container.encode(birthDate, forKey: .birthDate)
        try container.encode(calculatedAt, forKey: .calculatedAt)
    }
}

enum FortuneType: String, CaseIterable {
    case fourPillars = "四柱推命"
    case westernAstrology = "西洋占星術"
    case numerology = "数秘術"
    case tarot = "タロット"
    case nineStarKi = "九星気学"
    case bloodType = "血液型占い"
    case rokusei = "六星占術"
}

class FortuneTellingAPI {
    let baseURL: String
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    func testFourPillars(birthDate: String) async throws -> FortuneTellingResult {
        let url = URL(string: "\(baseURL)/api/fortune/four-pillars")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["birthDate": birthDate]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(FortuneTellingResult.self, from: data)
    }
    
    func testWesternAstrology(birthDate: String) async throws -> FortuneTellingResult {
        let url = URL(string: "\(baseURL)/api/fortune/western-astrology")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["birthDate": birthDate]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(FortuneTellingResult.self, from: data)
    }
    
    func testNumerology(birthDate: String) async throws -> FortuneTellingResult {
        let url = URL(string: "\(baseURL)/api/fortune/numerology")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["birthDate": birthDate]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(FortuneTellingResult.self, from: data)
    }
    
    func testTarot() async throws -> FortuneTellingResult {
        let url = URL(string: "\(baseURL)/api/fortune/tarot")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(FortuneTellingResult.self, from: data)
    }
    
    func testNineStarKi(birthDate: String) async throws -> FortuneTellingResult {
        let url = URL(string: "\(baseURL)/api/fortune/nine-star-ki")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["birthDate": birthDate]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(FortuneTellingResult.self, from: data)
    }
    
    func testBloodType(bloodType: String) async throws -> FortuneTellingResult {
        let url = URL(string: "\(baseURL)/api/fortune/blood-type")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["bloodType": bloodType]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(FortuneTellingResult.self, from: data)
    }
    
    func testRokusei(birthDate: String) async throws -> FortuneTellingResult {
        let url = URL(string: "\(baseURL)/api/fortune/rokusei")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["birthDate": birthDate]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(FortuneTellingResult.self, from: data)
    }
}