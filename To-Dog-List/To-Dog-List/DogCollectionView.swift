//
//  DogCollectionView.swift
//  To-Dog-List
//
//  Created by Michael on 4/21/26.
//

import SwiftUI

struct DogCollectionView: View {
    @State private var user: User? = UserDatabase.shared.getLoggedInUser()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Image(systemName: "pawprint.circle.fill")
                    .resizable()
                    .frame(width: 90, height: 90)
                    .foregroundColor(.orange)
                    .padding(.top, 20)

                Text("My Dogs")
                    .font(.title)
                    .fontWeight(.bold)

                if let user = user, !user.collectedDogs.isEmpty {
                    List(user.collectedDogs, id: \.self) { dog in
                        Text(dog)
                    }
                } else {
                    Spacer()
                    Text("No dogs collected yet.")
                        .foregroundColor(.secondary)
                    Text("Complete tasks to start building your dog collection.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                }
            }
            .navigationTitle("Dogs")
            .onAppear {
                user = UserDatabase.shared.getLoggedInUser()
            }
        }
    }
}

struct DogCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        DogCollectionView()
    }
}
