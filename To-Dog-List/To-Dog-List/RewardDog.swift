// Reward System (implemented fully when doing Tasks)

import Foundation

enum DogRarity: CaseIterable {
    case common, rare, epic
}

struct Dog {
    let name: String
    let rarity: DogRarity
}

struct Dogbox {
    static func generateDog() -> Dog {
        let roll = Int.random(in: 1...50)
        
        let rarity: DogRarity
        
        switch roll {
        case 1...33:
            rarity = .common
        case 33...47:
            rarity = .rare
        default:
            rarity = .epic
        }
        
        return randomDog(for: rarity)
    }
    
    static func randomDog(for rarity: DogRarity) -> Dog {
        let dogsByRarity: [DogRarity: [Dog]] = [
            
            .common: [
                Dog(name: "Beagle", rarity: .common),
                Dog(name: "Corgi", rarity: .common),
                Dog(name: "Pug", rarity: .common),
                Dog(name: "Dachshund", rarity: .common),
                Dog(name: "Chihuahua", rarity: .common),
                Dog(name: "Doberman", rarity: .common),
                Dog(name: "Bulldog", rarity: .common),
                Dog(name: "German Shepherd", rarity: .common),
                Dog(name: "Boston Terrier", rarity: .common),
                Dog(name: "Mini Pinscher", rarity: .common),
                Dog(name: "Husky", rarity: .common),
                Dog(name: "Golden Retriever", rarity: .common)
            ],
            
            .rare: [
                Dog(name: "Husky", rarity: .rare),
                Dog(name: "Dalmatian", rarity: .rare),
                Dog(name: "Akita", rarity: .rare),
                Dog(name: "Water Dog", rarity: .rare),
                Dog(name: "Fire Dog", rarity: .rare),
                Dog(name: "Grass Dog", rarity: .rare)
            ],
            
            .epic: [
                Dog(name: "Dragon Dog", rarity: .epic),
                Dog(name: "Phoenix Dog", rarity: .epic)
            ]
        ]
        
        return dogsByRarity[rarity]!.randomElement()!
    }
}
