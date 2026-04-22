import SwiftUI

//NAVBAR
struct ContentView: View{
    var body: some View {
        TabView{
            TaskListView()
                .tabItem{
                    Label("Tasks", systemImage: "checklist")
                }
            DogCollectionView()
                .tabItem{
                    Label("Dogs", systemImage: "pawprint.fill")
                }
            ProfileView()
                .tabItem{
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}

//
struct TaskListView: View {
    @State private var tasks: [TodoistTask] = []
    @State private var newTaskContent = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    @State private var togglingTaskId: String? = nil
    
    // Edit state
    @State private var editingTask: TodoistTask? = nil
    @State private var editedContent = ""
    @State private var showEditAlert = false
    
    // Delete state
    @State private var deletingTaskId: String? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                //MARK: Add new task input (as a card as well)
                HStack {
                    TextField("New task...", text: $newTaskContent)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Button(action: addTask) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                    .disabled(newTaskContent.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                Divider()
                
                // MARK: Task list
                if isLoading && tasks.isEmpty {
                    Spacer()
                    ProgressView("Loading tasks…")
                    Spacer()
                } else {
                    List {
                        ForEach(tasks) { task in
                            TaskCardView(
                                task: task,
                                isToggling: togglingTaskId == task.id,
                                isDeleting: deletingTaskId == task.id,
                                onToggle: { toggleCompletion(for: task) },
                                onEdit: { startEditing(task) },
                                onDelete: { deleteTask(task) }
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
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
        .alert("Edit Task", isPresented: $showEditAlert, presenting: editingTask) { task in
            TextField("Task content", text: $editedContent)
            Button("Cancel", role: .cancel) {
                editingTask = nil
                editedContent = ""
            }
            Button("Save") {
                updateTask(task, with: editedContent)
            }
        } message: { task in
            Text("Update \"\(task.content)\"")
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

    // MARK: Adding new task function
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

    // MARK: Toggle completion of task function
    private func toggleCompletion(for task: TodoistTask) {
        guard togglingTaskId == nil else { return }
        togglingTaskId = task.id

        let completion: (Result<Void, Error>) -> Void = { result in
            DispatchQueue.main.async {
                togglingTaskId = nil
                switch result {
                case .success:
                    if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                        let toggledTask = TodoistTask(
                            id: task.id,
                            content: task.content,
                            isCompleted: !task.isCompleted
                        )
                        tasks[index] = toggledTask
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }

        if task.isCompleted {
            TodoistAPIManager.shared.reopenTask(id: task.id, completion: completion)
        } else {
            TodoistAPIManager.shared.closeTask(id: task.id, completion: completion)
        }
    }
    
    // MARK: Start editing the current task function
    private func startEditing(_ task: TodoistTask) {
        editingTask = task
        editedContent = task.content
        showEditAlert = true
    }
    
    // MARK: Update the current task function
    private func updateTask(_ task: TodoistTask, with newContent: String) {
        let trimmed = newContent.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            editingTask = nil
            editedContent = ""
            return
        }
        
        TodoistAPIManager.shared.updateTask(id: task.id, content: trimmed) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedTask):
                    if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                        tasks[index] = updatedTask
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
                editingTask = nil
                editedContent = ""
            }
        }
    }
    
    // MARK: Delete the current task function
    private func deleteTask(_ task: TodoistTask) {
        deletingTaskId = task.id
        TodoistAPIManager.shared.deleteTask(id: task.id) { result in
            DispatchQueue.main.async {
                deletingTaskId = nil
                switch result {
                case .success:
                    tasks.removeAll { $0.id == task.id }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}

// MARK: - Task Card View UI layout
struct TaskCardView: View {
    let task: TodoistTask
    let isToggling: Bool
    let isDeleting: Bool
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion toggle button
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            .disabled(isToggling || isDeleting)
            .overlay {
                if isToggling {
                    ProgressView()
                }
            }
            
            //MARK: Task content
            Text(task.content)
                .font(.body)
                .strikethrough(task.isCompleted, color: .secondary)
                .foregroundColor(task.isCompleted ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            //MARK: Edit button
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.body)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            .disabled(isToggling || isDeleting)
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.body)
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .disabled(isToggling || isDeleting)
            .overlay {
                if isDeleting {
                    ProgressView()
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .opacity(isDeleting ? 0.6 : 1.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
