import SwiftUI

struct ContentView: View {
    @State private var tasks: [TodoistTask] = []
    @State private var newTaskContent = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false

    var body: some View {
        NavigationView {
            VStack {
                // Add new task input
                HStack {
                    TextField("New task...", text: $newTaskContent)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isLoading)

                    Button(action: addTask) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(newTaskContent.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                }
                .padding(.horizontal)
                .padding(.top)

                // Task list
                if isLoading && tasks.isEmpty {
                    Spacer()
                    ProgressView("Loading tasks…")
                    Spacer()
                } else {
                    List {
                        ForEach(tasks) { task in
                            HStack {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.isCompleted ? .green : .secondary)
                                Text(task.content)
                                    .strikethrough(task.isCompleted, color: .secondary)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await loadTasks()
                    }
                }
            }
            .navigationTitle("To‑Dog List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await loadTasks() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
        }
        .onAppear {
            Task { await loadTasks() }
        }
        .alert("Error", isPresented: $showErrorAlert, presenting: errorMessage) { _ in
            Button("OK", role: .cancel) { }
        } message: { message in
            Text(message)
        }
    }

    // MARK: - Networking

    private func loadTasks() async {
        await withCheckedContinuation { continuation in
            isLoading = true
            TodoistAPIManager.shared.fetchTasks { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let fetchedTasks):
                        tasks = fetchedTasks
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    }
                    continuation.resume()
                }
            }
        }
    }

    private func addTask() {
        let trimmed = newTaskContent.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        TodoistAPIManager.shared.createTask(content: trimmed) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let newTask):
                    tasks.insert(newTask, at: 0)
                    newTaskContent = ""
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
