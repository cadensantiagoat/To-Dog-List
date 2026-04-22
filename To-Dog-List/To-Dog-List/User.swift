// User.swift - User model: stores auth data, progression, and dog collection.

import Foundation

struct User: Codable {
    var username: String
    var password: String
    var level: Int
    var completedTaskCount: Int
    var completedTaskIDs: [String]
    var collectedDogs: [CollectedDog]
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
        self.level = 0
        self.completedTaskCount = 0
        self.completedTaskIDs = []
        self.collectedDogs = []
    }

    enum CodingKeys: String, CodingKey {
        case username
        case password
        case level
        case completedTaskCount
        case completedTaskIDs
        case collectedDogs
        case points
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: .username)
        password = try container.decode(String.self, forKey: .password)
        level = try container.decodeIfPresent(Int.self, forKey: .level) ?? 0
        completedTaskCount = try container.decodeIfPresent(Int.self, forKey: .completedTaskCount) ?? 0
        completedTaskIDs = try container.decodeIfPresent([String].self, forKey: .completedTaskIDs) ?? []

        if level == 0, completedTaskCount == 0 {
            let legacyPoints = try container.decodeIfPresent(Int.self, forKey: .points) ?? 0
            completedTaskCount = max(0, legacyPoints / 10)
            level = User.level(forTotalCompletedTasks: completedTaskCount)
        }

        if let dogs = try? container.decode([CollectedDog].self, forKey: .collectedDogs) {
            collectedDogs = dogs
        } else if let legacyDogs = try? container.decode([String].self, forKey: .collectedDogs) {
            collectedDogs = legacyDogs.map {
                CollectedDog(
                    name: $0,
                    rarity: .common,
                    imageURL: nil
                )
            }
        } else {
            collectedDogs = []
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
        try container.encode(level, forKey: .level)
        try container.encode(completedTaskCount, forKey: .completedTaskCount)
        try container.encode(completedTaskIDs, forKey: .completedTaskIDs)
        try container.encode(collectedDogs, forKey: .collectedDogs)
    }

    var tasksRequiredForNextLevel: Int {
        max(1, (level + 1) * 5)
    }

    var completedTasksIntoCurrentLevel: Int {
        completedTaskCount - User.totalTasksRequired(toReach: level)
    }

    var tasksRequiredInCurrentLevel: Int {
        tasksRequiredForNextLevel
    }

    var expProgress: Double {
        let required = Double(tasksRequiredInCurrentLevel)
        guard required > 0 else { return 0.0 }
        return min(1.0, max(0.0, Double(completedTasksIntoCurrentLevel) / required))
    }

    static func totalTasksRequired(toReach level: Int) -> Int {
        guard level > 0 else { return 0 }
        return 5 * level * (level + 1) / 2
    }

    static func level(forTotalCompletedTasks tasks: Int) -> Int {
        var computedLevel = 0
        var required = 5
        var consumed = tasks
        while consumed >= required {
            consumed -= required
            computedLevel += 1
            required = (computedLevel + 1) * 5
        }
        return computedLevel
    }
}

struct CollectedDog: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let rarity: DogRarity
    let imageURL: String?
    let obtainedAt: Date

    init(id: UUID = UUID(), name: String, rarity: DogRarity, imageURL: String?, obtainedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.rarity = rarity
        self.imageURL = imageURL
        self.obtainedAt = obtainedAt
    }
}
