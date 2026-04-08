import Foundation

class TodoistAPIManager {
    static let shared = TodoistAPIManager()
    
    // Todoist REST API v2 base URL
    private let baseURL = "https://api.todoist.com/rest/v2/"
    
    // Test Access Token
    private let apiToken = Secrets.todoistAPIKey
    
    func fetchTasks(completion: @escaping (Result<[TodoistTask], Error>) -> Void) {
        guard let url = URL(string: baseURL + "tasks") else { return }
        
        var request = URLRequest(url: rul)
        request.addValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Handling network errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Ensuring we have data
            guard let data = data else { return }
            
            // Decode JSON into the Swift struct
            do {
                let tasks = try JSONDecoder().decode([TodoistTask].self, from: data )
                DispatchQueue.main.async {
                    completion(.success(tasks))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
