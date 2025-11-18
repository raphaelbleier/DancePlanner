import SwiftUI

struct FormationSettingsView: View {
    @Bindable var formation: Formation
    var project: Project
    
    var body: some View {
        Form {
            Section("Info") {
                TextField("Name", text: $formation.name)
                Text("Time: \(String(format: "%.2f", formation.timestamp))s")
            }
            
            Section("Costumes") {
                ForEach(project.dancers) { dancer in
                    HStack {
                        Text(dancer.name)
                        Spacer()
                        Menu {
                            Button("Default", action: { formation.costumeAssignments.removeValue(forKey: dancer.id) })
                            ForEach(project.costumes) { costume in
                                Button(action: { formation.costumeAssignments[dancer.id] = costume.id }) {
                                    HStack {
                                        Text(costume.name)
                                        if formation.costumeAssignments[dancer.id] == costume.id {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            if let costumeID = formation.costumeAssignments[dancer.id],
                               let costume = project.costumes.first(where: { $0.id == costumeID }) {
                                Text(costume.name)
                                    .foregroundStyle(costume.color)
                            } else {
                                Text("Default")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Formation Settings")
    }
}
