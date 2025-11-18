import SwiftUI
import SwiftData

struct CostumeListView: View {
    var project: Project
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false
    @State private var newCostumeName = ""
    
    var body: some View {
        List {
            ForEach(project.costumes) { costume in
                NavigationLink(destination: EditCostumeView(costume: costume)) {
                    HStack {
                        Circle()
                            .fill(costume.color)
                            .frame(width: 30, height: 30)
                        Text(costume.name)
                    }
                }
            }
            .onDelete(perform: deleteCostumes)
        }
        .navigationTitle("Costumes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddSheet = true }) {
                    Label("Add Costume", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationStack {
                Form {
                    TextField("Costume Name", text: $newCostumeName)
                }
                .navigationTitle("New Costume")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingAddSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            addCostume()
                            showingAddSheet = false
                        }
                        .disabled(newCostumeName.isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    private func addCostume() {
        let costume = Costume(name: newCostumeName)
        project.costumes.append(costume)
        newCostumeName = ""
    }
    
    private func deleteCostumes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let costume = project.costumes[index]
                modelContext.delete(costume)
                if let idx = project.costumes.firstIndex(of: costume) {
                    project.costumes.remove(at: idx)
                }
            }
        }
    }
}

struct EditCostumeView: View {
    @Bindable var costume: Costume
    
    var body: some View {
        Form {
            Section("Details") {
                TextField("Name", text: $costume.name)
                ColorPicker("Color", selection: $costume.color)
                TextEditor(text: $costume.notes)
                    .frame(minHeight: 100)
            }
        }
        .navigationTitle("Edit Costume")
    }
}
