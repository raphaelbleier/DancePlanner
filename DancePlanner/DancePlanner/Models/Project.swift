import SwiftData
import Foundation

@Model
final class Project {
    var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade) var dancers: [Dancer] = []
    @Relationship(deleteRule: .cascade) var groups: [DancerGroup] = []
    @Relationship(deleteRule: .cascade) var costumes: [Costume] = []
    @Relationship(deleteRule: .cascade) var formations: [Formation] = []
    @Relationship(deleteRule: .cascade) var stageConfig: StageConfig?
    
    var audioFilename: String? // Filename in Documents directory
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
        self.stageConfig = StageConfig()
    }
}

@Model
final class StageConfig {
    var width: Double // in meters
    var depth: Double // in meters
    var shape: StageShape
    
    init(width: Double = 10.0, depth: Double = 8.0, shape: StageShape = .rectangle) {
        self.width = width
        self.depth = depth
        self.shape = shape
    }
}

enum StageShape: String, Codable {
    case rectangle
    case circle
    case oval
}
