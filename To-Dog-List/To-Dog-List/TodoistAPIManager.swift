import Foundation

class TodoistAPIManager {
    static let shared = TodoistAPIManager()
    
    // Todoist api v1 base URL
    private let baseURL = "https://api.todoist.com/api/v1/"
    
    // Test Access Token
    private let apiToken = Secrets.todoistAPIKey
    
    /// Fetches the user's active tasks from Todoist
    ///
    /// Use this function whenever you need to refresh the main task list. It automatically handles decoding the paginated v1 JSON response
    ///
    /// Returns a Result containing either an array of 'TodoistTask' objects on success, or an Error on failure
    func fetchTasks(completion: @escaping (Result<[TodoistTask], Error>) -> Void) {
        guard let url = URL(string: baseURL + "tasks") else { return }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Handling network errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Ensuring we have data
            guard let data = data else { return }
            
            if let rawString = String(data: data, encoding: .utf8) {
                print("RAW SERVER RESPONSE: \(rawString)")
            }
            
            // Decode JSON into the Swift struct
            do {
                // Decode the new v1 wrapper object first
                let taskResponse = try JSONDecoder().decode(TaskResponse.self, from: data)
                        
                // Extract the actual array of tasks from the "results" property
                let tasks = taskResponse.results
                        
                // Pass the extracted tasks safely back to the completion handler
                completion(.success(tasks))
                        
            } catch {
                print("Detailed JSON Error: \(error)")
                    completion(.failure(error))
            }        }
        task.resume()
    }
}
