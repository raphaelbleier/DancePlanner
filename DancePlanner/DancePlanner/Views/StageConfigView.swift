import SwiftUI

struct StageConfigView: View {
    @Bindable var config: StageConfig
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section("Dimensions") {
                HStack {
                    Text("Width")
                    Spacer()
                    TextField("Width", value: $config.width, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("m")
                }
                
                HStack {
                    Text("Depth")
                    Spacer()
                    TextField("Depth", value: $config.depth, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("m")
                }
            }
            
            Section("Shape") {
                Picker("Shape", selection: $config.shape) {
                    Text("Rectangle").tag(StageShape.rectangle)
                    Text("Circle").tag(StageShape.circle)
                    Text("Oval").tag(StageShape.oval)
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Stage Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}
