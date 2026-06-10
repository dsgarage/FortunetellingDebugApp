import Foundation

struct Brief: Identifiable, Codable {
    let id: Int
    let status: String
    let targetHandle: String
    let topic: String
    let draftText: String
    let targetUrl: String
    let editedText: String?
    
    var displayText: String {
        editedText ?? draftText
    }
    
    var shortText: String {
        String(displayText.prefix(50)) + (displayText.count > 50 ? "..." : "")
    }
}