import SwiftData
import SwiftUI

@Model
final class Costume {
    var id: UUID
    var name: String
    var colorHex: String
    var notes: String
    
    var project: Project?
    
    init(name: String, color: Color = .purple) {
        self.id = UUID()
        self.name = name
        self.colorHex = color.toHex() ?? "#800080"
        self.notes = ""
    }
    
    var color: Color {
        get { Color(hex: colorHex) ?? .purple }
        set { colorHex = newValue.toHex() ?? "#800080" }
    }
}
