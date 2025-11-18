import SwiftUI
import SwiftData

struct GroupListView: View {
    var project: Project
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false
    @State private var newGroupName = ""
    
    var body: some View {
        List {
            ForEach(project.groups) { group in
                NavigationLink(destination: EditGroupView(group: group, project: project)) {
                    HStack {
                        Image(systemName: "person.3.fill")
                        Text(group.name)
                        Spacer()
                        Text("\(group.dancers.count) dancers")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteGroups)
        }
        .navigationTitle("Groups")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddSheet = true }) {
                    Label("Add Group", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationStack {
                Form {
                    TextField("Group Name", text: $newGroupName)
                }
                .navigationTitle("New Group")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingAddSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            addGroup()
                            showingAddSheet = false
                        }
                        .disabled(newGroupName.isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    private func addGroup() {
        let group = DancerGroup(name: newGroupName)
        project.groups.append(group)
        newGroupName = ""
    }
    
    private func deleteGroups(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let group = project.groups[index]
                modelContext.delete(group)
                if let idx = project.groups.firstIndex(of: group) {
                    project.groups.remove(at: idx)
                }
            }
        }
    }
}

struct EditGroupView: View {
    @Bindable var group: DancerGroup
    var project: Project
    
    var body: some View {
        Form {
            Section("Info") {
                TextField("Name", text: $group.name)
            }
            
            Section("Members") {
                ForEach(project.dancers) { dancer in
                    HStack {
                        Text(dancer.name)
                        Spacer()
                        if group.dancers.contains(dancer) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleMember(dancer)
                    }
                }
            }
        }
        .navigationTitle("Edit Group")
    }
    
    private func toggleMember(_ dancer: Dancer) {
        if let index = group.dancers.firstIndex(of: dancer) {
            group.dancers.remove(at: index)
        } else {
            group.dancers.append(dancer)
        }
    }
}
