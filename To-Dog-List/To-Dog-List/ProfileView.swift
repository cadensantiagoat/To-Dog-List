//
//  ProfileView.swift
//  To-Dog-List
//
//  Created by Michael on 4/21/26.
//

import SwiftUI

struct ProfileView: View {
    @State private var user: User? = UserDatabase.shared.getLoggedInUser()
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.orange)
                    .padding(.top, 20)

                if let user = user {
                    Text(user.username)
                        .font(.title)
                        .fontWeight(.bold)

                    VStack(spacing: 12) {
                        HStack {
                            Text("Points")
                            Spacer()
                            Text("\(user.points)")
                                .fontWeight(.semibold)
                        }

                        HStack {
                            Text("Dogs Collected")
                            Spacer()
                            Text("\(user.collectedDogs.count)")
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                } else {
                    Text("No user profile found.")
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .onAppear {
                user = UserDatabase.shared.getLoggedInUser()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
