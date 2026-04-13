import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Testing Todoist API...")
        }
        .padding()
        .onAppear {
            testFetchTasks()
        }
    }
    
    func testFetchTasks() {
        print("Starting network request...")
        
        TodoistAPIManager.shared.fetchTasks { result in
            switch result {
            case .success(let tasks):
                print("Success! Fetched \(tasks.count) tasks.")
                for task in tasks {
                    print(" - Task: \(task.content) | Completed: \(task.isCompleted)")
                }
            case .failure(let error):
                print("Error: Failed to fetch tasks.")
                print(error.localizedDescription)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
