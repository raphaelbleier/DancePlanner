import SwiftData
import Foundation

@Model
final class DancerGroup {
    var id: UUID
    var name: String
    
    @Relationship(inverse: \Dancer.groups) var dancers: [Dancer] = []
    var project: Project?
    
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
