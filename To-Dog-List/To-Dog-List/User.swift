// User.swift - User model: stores the username, password,
// their points total, and the list of dog breeds they've collected.

import Foundation

struct User: Codable {
    var username: String
    var password: String
    var points: Int
    var collectedDogs: [String]  // stores breed names they've unlocked
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
        self.points = 0
        self.collectedDogs = []
    }
}
