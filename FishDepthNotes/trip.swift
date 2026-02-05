
import Foundation

struct Trip: Identifiable, Codable {
    let id: UUID
    var name: String
    var place: String
    var date: Date
    var holes: [Hole] = []
    
    init(id: UUID = UUID(), name: String, place: String, date: Date, holes: [Hole] = []) {
        self.id = id
        self.name = name
        self.place = place
        self.date = date
        self.holes = holes
    }
    
    var avgDepth: Double {
        guard !holes.isEmpty else { return 0 }
        return holes.map { $0.depth }.reduce(0, +) / Double(holes.count)
    }
    
    var totalCatch: Int {
        holes.map { $0.catchCount }.reduce(0, +)
    }
}
