import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggedIn = false
    @State private var showError = false
    @State private var pulseOpacity: Double = 0
    @State private var errorScale: CGFloat = 1.0

    var body: some View {
        if isLoggedIn {
            ContentView()
        } else {
            ZStack {
                ColorSchemes.backgroundColor
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
                        .foregroundColor(ColorSchemes.primaryColor)
                    
                    Text("Do tasks. Win dogs. Collect 'em all.")
                        .font(.subheadline)
                        .foregroundColor(ColorSchemes.tertiaryColor)
                    
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
                            .foregroundColor(.white)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.85))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red, lineWidth: 1.5)
                                    .opacity(pulseOpacity)
                            )
                            .scaleEffect(errorScale)
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                            .animation(.spring(response: 0.4, dampingFraction: 0.5), value: showError)
                    }
                    
                    // MARK: - Login Button
                    Button(action: handleLogin) {
                        Text("Log In")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ColorSchemes.primaryColor)
                            .foregroundColor(ColorSchemes.backgroundColor)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Register Button
                    Button(action: handleRegister) {
                        Text("Create Account")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ColorSchemes.secondaryColor)
                            .foregroundColor(ColorSchemes.backgroundColor)
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
            shakeError()
            return
        }
        if let user = UserDatabase.shared.loginUser(username: username, password: password) {
            UserDatabase.shared.setLoggedInUser(user)
            isLoggedIn = true
            showError = false
        } else {
            errorMessage = "Invalid username or password."
            showError = true
            shakeError()
        }
    }
    
    private func shakeError() {
        // Pop in
        errorScale = 0.8
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
            errorScale = 1.05
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.15)) {
                errorScale = 1.0
            }
        }

        // Pulse glow
        withAnimation(.easeIn(duration: 0.2)) {
            pulseOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.6).repeatCount(2, autoreverses: true)) {
                pulseOpacity = 0.2
            }
        }
    }
    
    // MARK: - Register Logic
    private func handleRegister() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter a username and password."
            showError = true
            shakeError()
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
            shakeError()
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
