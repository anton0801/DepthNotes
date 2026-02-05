
import Foundation
import Combine

class DataStore: ObservableObject {
    @Published var trips: [Trip] = [] {
        didSet {
            saveTrips()
        }
    }
    
    private let tripsFileURL: URL = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("trips.json")
    }()
    
    init() {
        loadTrips()
        if trips.isEmpty {
            loadSampleData()
        }
    }
    
    func loadSampleData() {
        trips = [
            Trip(
                name: "Lake 12 Jan",
                place: "Crystal Lake",
                date: Date(),
                holes: [
                    Hole(number: 1, depth: 3.5, bottomType: .sand, bait: "Jig", biteScore: 4, catchCount: 2, species: ["Perch"], notes: ""),
                    Hole(number: 2, depth: 5.2, bottomType: .silt, bait: "Minnow", biteScore: 5, catchCount: 3, species: ["Pike"], notes: "")
                ]
            )
        ]
    }
    
    func addTrip(_ trip: Trip) {
        trips.insert(trip, at: 0)
    }
    
    func updateTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
        }
    }
    
    func deleteTrip(_ trip: Trip) {
        trips.removeAll { $0.id == trip.id }
    }
    
    // MARK: - Persistence
    private func saveTrips() {
        do {
            let data = try JSONEncoder().encode(trips)
            try data.write(to: tripsFileURL, options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to save trips: \(error.localizedDescription)")
        }
    }
    
    private func loadTrips() {
        do {
            let data = try Data(contentsOf: tripsFileURL)
            trips = try JSONDecoder().decode([Trip].self, from: data)
        } catch {
            print("Failed to load trips: \(error.localizedDescription)")
            trips = []
        }
    }
}
