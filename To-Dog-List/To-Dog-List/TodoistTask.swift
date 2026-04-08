import Foundation

struct TodoistTask: Codable {
    let id: String
    let content: String
    let isCompleted: Bool
    
    // Maps JSON keys from Todoist to Swift property names
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case isCompleted = "is_completed"
    }
}
