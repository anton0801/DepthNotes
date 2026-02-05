
import SwiftUI

struct TripDetailView: View {
    let tripId: UUID
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var showAddHole = false
    @State private var selectedHole: Hole?
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#FFF5EB"), Color(hex: "#FFE5CC")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if let trip = store.trips.first(where: { $0.id == tripId }) {
                VStack(spacing: 0) {
                    // Stats Header
                    HStack(spacing: 12) {
                        StatBox(title: "Holes", value: "\(trip.holes.count)", icon: "circle.fill", gradient: ["#FF8C42", "#FF6B35"])
                        StatBox(title: "Avg Depth", value: String(format: "%.1fm", trip.avgDepth), icon: "ruler.fill", gradient: ["#FFD93D", "#FFA500"])
                        StatBox(title: "Catch", value: "\(trip.totalCatch)", icon: "fish.fill", gradient: ["#6BCF9D", "#3A9B7A"])
                    }
                    .padding()
                    
                    if trip.holes.isEmpty {
                        EmptyStateView(
                            icon: "circle.fill",
                            title: "No holes yet",
                            description: "Add your first hole"
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(trip.holes) { hole in
                                    Button(action: { selectedHole = hole }) {
                                        HoleCard(hole: hole)
                                    }
                                    .buttonStyle(CardButtonStyle())
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            withAnimation {
                                                if let tripIndex = store.trips.firstIndex(where: { $0.id == tripId }) {
                                                    store.trips[tripIndex].holes.removeAll { $0.id == hole.id }
                                                }
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle(trip.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button(role: .destructive, action: {
                                store.deleteTrip(trip)
                                dismiss()
                            }) {
                                Label("Delete Trip", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(Color(hex: "#2C3E50"))
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showAddHole = true }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#FF8C42"), Color(hex: "#FF6B35")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)
                                    .shadow(color: Color(hex: "#FF8C42").opacity(0.4), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .sheet(isPresented: $showAddHole) {
                    HoleEditorView(tripId: tripId)
                        .environmentObject(store)
                }
                .sheet(item: $selectedHole) { hole in
                    HoleDetailView(tripId: tripId, holeId: hole.id)
                        .environmentObject(store)
                }
            } else {
                Text("Trip not found")
                    .foregroundColor(Color(hex: "#2C3E50"))
            }
        }
    }
}
