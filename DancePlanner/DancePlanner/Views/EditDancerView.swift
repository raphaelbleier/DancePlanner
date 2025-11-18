import SwiftUI

struct EditDancerView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var dancer: Dancer
    
    var body: some View {
        Form {
            Section("Profile") {
                TextField("Name", text: $dancer.name)
                ColorPicker("Color", selection: $dancer.color)
                Stepper(value: $dancer.height, in: 1.0...2.5, step: 0.01) {
                    HStack {
                        Text("Height")
                        Spacer()
                        Text(String(format: "%.2f m", dancer.height))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Notes") {
                TextEditor(text: $dancer.notes)
                    .frame(minHeight: 100)
            }
        }
        .navigationTitle("Edit Dancer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}
