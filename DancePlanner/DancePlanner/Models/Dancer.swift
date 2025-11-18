import SwiftData
import SwiftUI

@Model
final class Dancer {
    var id: UUID
    var name: String
    var colorHex: String
    var height: Double // in meters
    var notes: String
    
    @Relationship(deleteRule: .cascade) var placements: [Placement] = []
    var groups: [DancerGroup] = []
    
    init(name: String, color: Color = .blue, height: Double = 1.7) {
        self.id = UUID()
        self.name = name
        self.colorHex = color.toHex() ?? "#0000FF"
        self.height = height
        self.notes = ""
    }
    
    var color: Color {
        get { Color(hex: colorHex) ?? .blue }
        set { colorHex = newValue.toHex() ?? "#0000FF" }
    }
}

// Helper for Color serialization
extension Color {
    func toHex() -> String? {
        // Implementation placeholder for Color to Hex conversion
        return "#0000FF" 
    }
    
    init?(hex: String) {
        // Implementation placeholder for Hex to Color initialization
        self.init(.blue)
    }
}
