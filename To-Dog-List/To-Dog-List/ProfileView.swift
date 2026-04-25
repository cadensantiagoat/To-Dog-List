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
            ZStack {
                ColorSchemes.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(ColorSchemes.primaryColor)
                        .padding(.top, 20)
                    
                    if let user = user {
                        Text(user.username)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(ColorSchemes.tertiaryColor)
                        
                        
                        // Levels + Exp of User
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Level \(user.level)")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("Next: Level \(user.level + 1)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                ProgressView(value: user.expProgress)
                                    .tint(.orange)
                                
                                Text("\(user.completedTasksIntoCurrentLevel)/\(user.tasksRequiredInCurrentLevel) tasks")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("Dogs Collected")
                                Spacer()
                                Text("\(user.collectedDogs.count)")
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Text("Total Tasks Completed")
                                Spacer()
                                Text("\(user.completedTaskCount)")
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
            }
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
