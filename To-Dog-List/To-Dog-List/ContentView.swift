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
    @State private var latestRewardDog: CollectedDog?

    var body: some View {
        NavigationView {
            ZStack {
                ColorSchemes.backgroundColor
                    .ignoresSafeArea()
                
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
                    .background(ColorSchemes.backgroundColor)
                    
                    Divider()
                    
                    // MARK: Task list
                    if isLoading && tasks.isEmpty {
                        Spacer()
                        ProgressView("Loading tasks…")
                            .foregroundColor(.white)
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
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("To-Dog List")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 100)
                        .foregroundColor(ColorSchemes.primaryColor)
                }
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
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            if UserDatabase.shared.getLoggedInUser() == nil {
                 tasks = []
                 return
            }

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
        .sheet(item: $latestRewardDog) { dog in
            VStack(spacing: 16) {
                Text("New Dog Unlocked!")
                    .font(.title2)
                    .fontWeight(.bold)

                if let imageURL = dog.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 220, height: 220)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 220, height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        case .failure:
                            ProgressView()
                                .frame(width: 220, height: 220)
                        @unknown default:
                            ProgressView()
                                .frame(width: 220, height: 220)
                        }
                    }
                }

                Text(dog.name)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("\(dog.rarity.displayName) Rarity")
                    .font(.headline)
                    .foregroundColor(colorForRarity(dog.rarity))

                Button("Awesome!") {
                    latestRewardDog = nil
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
            .padding(24)
            .presentationDetents([.medium])
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
                    if !task.isCompleted {
                        handleTaskCompletionReward(taskID: task.id)
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

    private func handleTaskCompletionReward(taskID: String) {
        guard let user = UserDatabase.shared.getLoggedInUser() else { return }
        guard let progress = UserDatabase.shared.recordTaskCompletion(taskID: taskID, for: user.username) else {
            return
        }
        guard progress.didLevelUp else { return }

        let rarity = Dogbox.rollRarity()
        DogAPIManager.shared.fetchRandomDog { dogResult in
            DispatchQueue.main.async {
                let reward = CollectedDog(name: dogResult.breed, rarity: rarity, imageURL: dogResult.imageURL)
                UserDatabase.shared.addDogToCollection(reward, for: user.username)
                latestRewardDog = reward
            }
        }
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
