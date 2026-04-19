import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggedIn = false
    @State private var showError = false
    
    // Team color palette
    let primaryColor = Color(hex: "#F7A325")
    let secondaryColor = Color(hex: "#53D892")
    let backgroundColor = Color(hex: "#1A1C2C")
    let tertiaryColor = Color(hex: "#FFD18B")

    var body: some View {
        if isLoggedIn {
            ContentView()
        } else {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    // MARK: - App Icon / Title
                    Image("DogLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .cornerRadius(24)
                        .padding(.top, 40)
                    
                    Text("To-Dog List")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(primaryColor)
                    
                    Text("Do tasks. Win dogs. Collect 'em all.")
                        .font(.subheadline)
                        .foregroundColor(tertiaryColor)
                    
                    Spacer().frame(height: 10)
                    
                    // MARK: - Input Fields
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .padding(.horizontal)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    // MARK: - Error Message
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    // MARK: - Login Button
                    Button(action: handleLogin) {
                        Text("Log In")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(primaryColor)
                            .foregroundColor(backgroundColor)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Register Button
                    Button(action: handleRegister) {
                        Text("Create Account")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(secondaryColor)
                            .foregroundColor(backgroundColor)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Login Logic
    private func handleLogin() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter a username and password."
            showError = true
            return
        }
        if let user = UserDatabase.shared.loginUser(username: username, password: password) {
            UserDatabase.shared.setLoggedInUser(user)
            isLoggedIn = true
            showError = false
        } else {
            errorMessage = "Invalid username or password."
            showError = true
        }
    }
    
    // MARK: - Register Logic
    private func handleRegister() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter a username and password."
            showError = true
            return
        }
        let success = UserDatabase.shared.registerUser(username: username, password: password)
        if success {
            if let user = UserDatabase.shared.loginUser(username: username, password: password) {
                UserDatabase.shared.setLoggedInUser(user)
                isLoggedIn = true
                showError = false
            }
        } else {
            errorMessage = "Username already taken. Please choose a different username."
            showError = true
        }
    }
}

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
