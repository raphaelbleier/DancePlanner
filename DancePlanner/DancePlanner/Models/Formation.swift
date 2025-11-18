import SwiftData
import Foundation

@Model
final class Formation {
    var id: UUID
    var name: String
    var timestamp: TimeInterval // Position in timeline
    var duration: TimeInterval? // Optional duration if it's a hold
    
    @Relationship(deleteRule: .cascade) var placements: [Placement] = []
    var project: Project?
    
    // DancerID -> CostumeID
    var costumeAssignments: [UUID: UUID] = [:]
    
    init(name: String, timestamp: TimeInterval) {
        self.id = UUID()
        self.name = name
        self.timestamp = timestamp
    }
}

@Model
final class Placement {
    var id: UUID
    var x: Double // Normalized 0-1 or meters
    var y: Double // Normalized 0-1 or meters
    var rotation: Double // In degrees
    
    var dancer: Dancer?
    var formation: Formation?
    
    init(x: Double, y: Double, rotation: Double = 0, dancer: Dancer) {
        self.id = UUID()
        self.x = x
        self.y = y
        self.rotation = rotation
        self.dancer = dancer
    }
}
