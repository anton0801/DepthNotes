
import Foundation

struct Hole: Identifiable, Codable {
    let id: UUID
    var number: Int
    var depth: Double
    var distanceFromShore: Double?
    var bottomType: BottomType
    var bait: String
    var timeStart: Date?
    var timeEnd: Date?
    var biteScore: Int
    var catchCount: Int
    var species: [String]
    var notes: String
    
    init(id: UUID = UUID(), number: Int, depth: Double, distanceFromShore: Double? = nil, bottomType: BottomType, bait: String, timeStart: Date? = nil, timeEnd: Date? = nil, biteScore: Int, catchCount: Int, species: [String], notes: String) {
        self.id = id
        self.number = number
        self.depth = depth
        self.distanceFromShore = distanceFromShore
        self.bottomType = bottomType
        self.bait = bait
        self.timeStart = timeStart
        self.timeEnd = timeEnd
        self.biteScore = biteScore
        self.catchCount = catchCount
        self.species = species
        self.notes = notes
    }
}
