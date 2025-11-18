import SwiftUI
import SwiftData

struct SidebarView: View {
    @Binding var selectedProject: Project?
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.updatedAt, order: .reverse) private var projects: [Project]
    
    @State private var showingNewProjectSheet = false

    var body: some View {
        List(selection: $selectedProject) {
            Section("Projects") {
                ForEach(projects) { project in
                    NavigationLink(value: project) {
                        Text(project.name)
                    }
                }
                .onDelete(perform: deleteProjects)
            }
        }
        .navigationTitle("Dance Planner")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingNewProjectSheet = true }) {
                    Label("Add Project", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewProjectSheet) {
            NewProjectSheet()
        }
    }

    private func deleteProjects(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(projects[index])
            }
        }
    }
}

struct NewProjectSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State private var name = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Project Name", text: $name)
            }
            .navigationTitle("New Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let newProject = Project(name: name)
                        modelContext.insert(newProject)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
