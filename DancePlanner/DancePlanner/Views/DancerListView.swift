import SwiftUI
import SwiftData

struct DancerListView: View {
    var project: Project
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false
    @State private var newDancerName = ""
    
    var body: some View {
        List {
            ForEach(project.dancers) { dancer in
                NavigationLink(destination: EditDancerView(dancer: dancer)) {
                    HStack {
                        Circle()
                            .fill(dancer.color)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text(dancer.name.prefix(1).uppercased())
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            )
                        
                        VStack(alignment: .leading) {
                            Text(dancer.name)
                                .font(.headline)
                            Text(String(format: "%.2f m", dancer.height))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .onDelete(perform: deleteDancers)
        }
        .navigationTitle("Dancers")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddSheet = true }) {
                    Label("Add Dancer", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationStack {
                Form {
                    TextField("Name", text: $newDancerName)
                }
                .navigationTitle("New Dancer")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingAddSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            addDancer()
                            showingAddSheet = false
                        }
                        .disabled(newDancerName.isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    private func addDancer() {
        let dancer = Dancer(name: newDancerName)
        project.dancers.append(dancer)
        newDancerName = ""
    }
    
    private func deleteDancers(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let dancer = project.dancers[index]
                modelContext.delete(dancer)
                // Note: Relationship delete rule should handle removing from project, 
                // but since it's an array on Project, we might need to explicitly remove if not using inverse correctly.
                // However, SwiftData usually handles this if set up right. 
                // For explicit safety with array relationships:
                if let idx = project.dancers.firstIndex(of: dancer) {
                    project.dancers.remove(at: idx)
                }
            }
        }
    }
}
