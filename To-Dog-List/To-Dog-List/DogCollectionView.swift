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
            ZStack {
                ColorSchemes.backgroundColor
                    .ignoresSafeArea()
                
                VStack (spacing: 0) {
                    
                    VStack(spacing: 16) {
                        Image(systemName: "pawprint.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(ColorSchemes.primaryColor)
                            .padding(.top, 20)
                        
                        Text("My Collection")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(ColorSchemes.tertiaryColor)
                            .padding(.bottom)
                    }
                    .frame(maxWidth: .infinity)
                    .background(ColorSchemes.backgroundColor)
                    
                    if let user = user, !user.collectedDogs.isEmpty {
                        List(user.collectedDogs) { dog in
                            HStack(spacing: 12) {
                                if let imageURL = dog.imageURL, let url = URL(string: imageURL) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 64, height: 64)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 64, height: 64)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        case .failure:
                                            ProgressView()
                                                .frame(width: 64, height: 64)
                                        @unknown default:
                                            ProgressView()
                                                .frame(width: 64, height: 64)
                                        }
                                    }
                                } else {
                                    fallbackDogImage
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(dog.name)
                                        .font(.headline)
                                    Text(dog.rarity.displayName)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(colorForRarity(dog.rarity).opacity(0.2))
                                        .foregroundColor(colorForRarity(dog.rarity))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .scrollContentBackground(.hidden)
                    } else {
                        Spacer().frame(height: 200)
                        Text("No dogs collected yet.")
                            .foregroundColor(ColorSchemes.tertiaryColor)
                        Text("Complete tasks to start building your dog collection.")
                            .font(.subheadline)
                            .foregroundColor(ColorSchemes.tertiaryColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Spacer()
                    }
                }
            }
            .onAppear {
                user = UserDatabase.shared.getLoggedInUser()
            }
        }
    }

    private var fallbackDogImage: some View {
        Image(systemName: "pawprint.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 64, height: 64)
            .foregroundColor(ColorSchemes.primaryColor)
    }

    private func colorForRarity(_ rarity: DogRarity) -> Color {
        switch rarity {
        case .common:
            return .gray
        case .rare:
            return .blue
        case .epic:
            return .purple
        }
    }
}

struct DogCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        DogCollectionView()
    }
}
