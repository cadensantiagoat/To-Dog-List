import Foundation

class TodoistAPIManager {
    static let shared = TodoistAPIManager()
    
    // Todoist api v1 base URL
    private let baseURL = "https://api.todoist.com/api/v1/"
    
    // Test Access Token
    private let apiToken = "aded5eefba4dcec9efc1d12169dd6c1a329838bf"
    
    // MARK: -Fetch the Tasks
    /// Fetches the user's active tasks from Todoist
    ///
    /// Use this function whenever you need to refresh the main task list. It automatically handles decoding the paginated v1 JSON response
    ///
    /// Returns a Result containing either an array of 'TodoistTask' objects on success, or an Error on failure
    ///
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
    
    // MARK: - Create Task
    func createTask(content: String, completion: @escaping (Result<TodoistTask, Error>) -> Void) {
        guard let url = URL(string: baseURL + "tasks") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["content": content]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            // DEBUG: Print raw response
            if let rawString = String(data: data, encoding: .utf8) {
                print("RAW CREATE RESPONSE: \(rawString)")
            }
            
            do {
                let task = try JSONDecoder().decode(TodoistTask.self, from: data)
                completion(.success(task))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Close Task (Mark as Complete)
    func closeTask(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: baseURL + "tasks/\(id)/close") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            // Success: status code 204 No Content expected
            DispatchQueue.main.async { completion(.success(())) }
        }.resume()
    }

    // MARK: - Reopen Task (Mark as Incomplete)
    func reopenTask(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: baseURL + "tasks/\(id)/reopen") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            DispatchQueue.main.async { completion(.success(())) }
        }.resume()
    }
    
    // MARK: - Update Task
    func updateTask(id: String, content: String, completion: @escaping (Result<TodoistTask, Error>) -> Void) {
        guard let url = URL(string: baseURL + "tasks/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["content": content]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else { return }
            
            do {
                let updatedTask = try JSONDecoder().decode(TodoistTask.self, from: data)
                DispatchQueue.main.async { completion(.success(updatedTask)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    // MARK: - Delete Task
    func deleteTask(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: baseURL + "tasks/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            DispatchQueue.main.async { completion(.success(())) }
        }.resume()
    }
    
}
