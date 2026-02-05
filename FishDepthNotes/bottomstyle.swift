
import Foundation

enum BottomType: String, CaseIterable, Codable {
    case sand = "Sand"
    case silt = "Silt"
    case rock = "Rock"
    case mixed = "Mixed"
    case unknown = "Unknown"
    
    var icon: String {
        switch self {
        case .sand: return "⋯"
        case .silt: return "≋"
        case .rock: return "◆"
        case .mixed: return "◇"
        case .unknown: return "?"
        }
    }
}
