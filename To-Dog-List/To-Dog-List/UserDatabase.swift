// UserDatabase.swift: handles the persistent storage like registering users,
// logging in, saving who's logged in between app launches, and adding dogs
// to a collection with points.


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
    
    // Add a dog breed to the user's collection and award points
    func addDogToCollection(breed: String, for username: String) {
        var users = getAllUsers()
        if let index = users.firstIndex(where: { $0.username == username }) {
            if !users[index].collectedDogs.contains(breed) {
                users[index].collectedDogs.append(breed)
                users[index].points += 10
                saveAllUsers(users)
                setLoggedInUser(users[index])
            }
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
