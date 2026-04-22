// UserDatabase.swift: handles the persistent storage like registering users,
// logging in, saving who's logged in between app launches, progressing levels,
// and adding dogs to a collection.


import Foundation

class UserDatabase {
    static let shared = UserDatabase()
    
    private let usersKey = "savedUsers"
    private let loggedInUserKey = "loggedInUser"
    
    // Save a new user aka registration
    func registerUser(username: String, password: String) -> Bool {
        var users = getAllUsers()
        
        // Checks if username already exists
        if users.contains(where: { $0.username == username }) {
            return false  // username taken
        }
        
        let newUser = User(username: username, password: password)
        users.append(newUser)
        saveAllUsers(users)
        return true
    }
    
    // Checks credentials and return user if valid login
    func loginUser(username: String, password: String) -> User? {
        let users = getAllUsers()
        return users.first(where: { $0.username == username && $0.password == password })
    }
    
    // Save which user is currently logged in
    func setLoggedInUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: loggedInUserKey)
        }
    }
    
    // Get the currently logged in user
    func getLoggedInUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: loggedInUserKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
    
    // Log out
    func logoutUser() {
        UserDefaults.standard.removeObject(forKey: loggedInUserKey)
    }
    
    struct TaskCompletionProgress {
        let didLevelUp: Bool
        let newLevel: Int
    }

    // Record one unique task completion. Duplicate task IDs are ignored.
    func recordTaskCompletion(taskID: String, for username: String) -> TaskCompletionProgress? {
        var users = getAllUsers()
        guard let index = users.firstIndex(where: { $0.username == username }) else {
            return nil
        }

        if users[index].completedTaskIDs.contains(taskID) {
            return TaskCompletionProgress(didLevelUp: false, newLevel: users[index].level)
        }

        users[index].completedTaskIDs.append(taskID)
        users[index].completedTaskCount += 1

        let oldLevel = users[index].level
        let updatedLevel = User.level(forTotalCompletedTasks: users[index].completedTaskCount)
        users[index].level = updatedLevel

        saveAllUsers(users)
        setLoggedInUser(users[index])

        return TaskCompletionProgress(
            didLevelUp: updatedLevel > oldLevel,
            newLevel: updatedLevel
        )
    }

    // Add a dog to the user's collection.
    // Duplicate rewards are allowed to keep the "gacha" feel.
    func addDogToCollection(_ dog: CollectedDog, for username: String) {
        var users = getAllUsers()
        if let index = users.firstIndex(where: { $0.username == username }) {
            users[index].collectedDogs.append(dog)
            saveAllUsers(users)
            setLoggedInUser(users[index])
        }
    }
    
    // MARK: - Private Helpers
    
    private func getAllUsers() -> [User] {
        guard let data = UserDefaults.standard.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([User].self, from: data) else {
            return []
        }
        return users
    }
    
    private func saveAllUsers(_ users: [User]) {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }
}
