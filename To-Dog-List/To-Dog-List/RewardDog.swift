// Reward System (implemented fully when doing Tasks)

import Foundation

enum DogRarity: String, CaseIterable, Codable, Hashable {
    case common, rare, epic

    var displayName: String {
        rawValue.capitalized
    }
}

struct DogReward {
    let name: String
    let rarity: DogRarity
    let imageURL: String?
}

private struct RandomDogResponse: Decodable {
    let message: String
}

final class DogAPIManager {
    static let shared = DogAPIManager()
    private let randomDogEndpoint = "https://dog.ceo/api/breeds/image/random"

    func fetchRandomDog(completion: @escaping ((breed: String, imageURL: String)) -> Void) {
        guard let url = URL(string: randomDogEndpoint) else { return }
        fetchRandomDog(from: url, completion: completion)
    }

    private func fetchRandomDog(from url: URL, completion: @escaping ((breed: String, imageURL: String)) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Dog fetch failed, retrying: \(error.localizedDescription)")
                self.retryFetch(url: url, completion: completion)
                return
            }

            guard let data = data else {
                self.retryFetch(url: url, completion: completion)
                return
            }

            do {
                let response = try JSONDecoder().decode(RandomDogResponse.self, from: data)
                let breed = Self.extractBreed(from: response.message)
                completion((breed: breed, imageURL: response.message))
            } catch {
                print("Dog decode failed, retrying: \(error.localizedDescription)")
                self.retryFetch(url: url, completion: completion)
            }
        }.resume()
    }

    private func retryFetch(url: URL, completion: @escaping ((breed: String, imageURL: String)) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.4) {
            self.fetchRandomDog(from: url, completion: completion)
        }
    }

    private static func extractBreed(from imageURL: String) -> String {
        guard let url = URL(string: imageURL) else { return "Unknown Dog" }
        let parts = url.pathComponents
        guard let breedsIndex = parts.firstIndex(of: "breeds"), breedsIndex + 1 < parts.count else {
            return "Unknown Dog"
        }

        let breedIdentifier = parts[breedsIndex + 1]
        let breedParts = breedIdentifier.split(separator: "-").map { $0.capitalized }
        return breedParts.joined(separator: " ")
    }
}

struct Dogbox {
    static func rollRarity() -> DogRarity {
        let roll = Int.random(in: 1...50)

        switch roll {
        case 1...33:
            return .common
        case 34...47:
            return .rare
        default:
            return .epic
        }
    }
}
