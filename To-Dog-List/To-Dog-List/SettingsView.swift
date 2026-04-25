//
//  SettingsView.swift
//  To-Dog-List
//
//  Created by Michael on 4/21/26.
//

import SwiftUI

struct SettingsView: View {
    @State private var isLoggedOut = false
    @State private var showConfirmation = false

    var body: some View {
        ZStack {
            ColorSchemes.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .foregroundColor(ColorSchemes.primaryColor)
                    .padding(.top, 20)

                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(ColorSchemes.tertiaryColor)

                Spacer()
                
                Text("More settings coming soon.")
                    .foregroundColor(ColorSchemes.tertiaryColor.opacity(0.5))
                    .font(.subheadline)

                Spacer()

                // MARK: - Logout Button
                Button(action: {
                    showConfirmation = true
                }) {
                    Text("Log Out")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
                .confirmationDialog("Are you sure you want to log out?",
                                    isPresented: $showConfirmation,
                                    titleVisibility: .visible) {
                    Button("Log Out", role: .destructive) {
                        UserDatabase.shared.logoutUser()
                        isLoggedOut = true
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
        .navigationTitle("Settings")
        .fullScreenCover(isPresented: $isLoggedOut) {
            LoginView()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
