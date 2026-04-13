import Foundation

struct TodoistTask: Codable, Sendable {
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

struct TaskResponse: Codable, Sendable {
    let results: [TodoistTask]
}
