import Foundation

struct TodoistTask: Codable, Sendable, Identifiable {
    let id: String
    let content: String
    let isCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case isCompleted = "is_completed"
    }
    
    // Custom decoding for both id types and optional is_completed
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle id as String or Int
        if let stringId = try? container.decode(String.self, forKey: .id) {
            self.id = stringId
        } else if let intId = try? container.decode(Int.self, forKey: .id) {
            self.id = String(intId)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "id must be String or Int")
        }
        
        self.content = try container.decode(String.self, forKey: .content)
        
        // is_completed might be missing in create response; default to false
        self.isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
    }
}

struct TaskResponse: Codable, Sendable {
    let results: [TodoistTask]
}
