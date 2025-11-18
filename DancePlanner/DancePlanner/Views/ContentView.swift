import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    @State private var selectedProject: Project?

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedProject: $selectedProject)
        } detail: {
            if let project = selectedProject {
                ProjectDetailView(project: project)
            } else {
                ContentUnavailableView("Select a Project", systemImage: "music.note.list")
            }
        }
    }
}
