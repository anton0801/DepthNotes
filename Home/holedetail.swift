
import SwiftUI

struct HoleDetailView: View {
    let tripId: UUID
    let holeId: UUID
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#FFF5EB"), Color(hex: "#FFE5CC")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if let trip = store.trips.first(where: { $0.id == tripId }),
                   let hole = trip.holes.first(where: { $0.id == holeId }) {
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Depth Header with gradient
                        VStack(spacing: 12) {
                            Text(String(format: "%.1f", hole.depth))
                                .font(.system(size: 72, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "#FF8C42"), Color(hex: "#FF6B35")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("meters")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(hex: "#2C3E50").opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color(hex: "#FF8C42").opacity(0.3), Color(hex: "#FF8C42").opacity(0.1)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: Color(hex: "#FF8C42").opacity(0.2), radius: 20, x: 0, y: 10)
                        )
                        
                        // Details
                        SectionCard(title: "Details") {
                            VStack(spacing: 16) {
                                DetailRow(
                                    icon: "circle.grid.3x3.fill",
                                    label: "Bottom",
                                    value: "\(hole.bottomType.icon) \(hole.bottomType.rawValue)",
                                    gradient: ["#FF8C42", "#FF6B35"]
                                )
                                
                                Divider().background(Color(hex: "#2C3E50").opacity(0.1))
                                
                                DetailRow(
                                    icon: "f.cursive",
                                    label: "Bait",
                                    value: hole.bait,
                                    gradient: ["#FFD93D", "#FFA500"]
                                )
                                
                                Divider().background(Color(hex: "#2C3E50").opacity(0.1))
                                
                                HStack {
                                    HStack(spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color(hex: "#FFD93D"), Color(hex: "#FFA500")],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 32, height: 32)
                                            
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white)
                                        }
                                        Text("Bite Score")
                                            .foregroundColor(Color(hex: "#2C3E50").opacity(0.8))
                                    }
                                    Spacer()
                                    HStack(spacing: 3) {
                                        ForEach(0..<5) { i in
                                            Image(systemName: i < hole.biteScore ? "star.fill" : "star")
                                                .font(.system(size: 14))
                                                .foregroundColor(Color(hex: "#FFD93D"))
                                        }
                                    }
                                }
                                .font(.system(size: 16))
                                
                                if hole.catchCount > 0 {
                                    Divider().background(Color(hex: "#2C3E50").opacity(0.1))
                                    
                                    DetailRow(
                                        icon: "fish.fill",
                                        label: "Catch",
                                        value: "\(hole.catchCount)",
                                        gradient: ["#6BCF9D", "#3A9B7A"]
                                    )
                                }
                            }
                        }
                        
                        // Actions
                        VStack(spacing: 14) {
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "doc.on.doc.fill")
                                        .font(.system(size: 16))
                                    Text("Duplicate Hole")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color(hex: "#2C3E50").opacity(0.1), lineWidth: 1)
                                        )
                                        .shadow(color: Color(hex: "#FF8C42").opacity(0.08), radius: 4, x: 0, y: 2)
                                )
                                .foregroundColor(Color(hex: "#2C3E50"))
                            }
                            
                            Button(action: { deleteHole() }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 16))
                                    Text("Delete Hole")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "#FF6B6B"), Color(hex: "#C74444")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: Color(hex: "#FF6B6B").opacity(0.4), radius: 12, x: 0, y: 4)
                                )
                                .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(20)
                }
                .navigationTitle("Hole #\(hole.number)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(Color(hex: "#FF8C42"))
                        .font(.system(size: 17, weight: .semibold))
                    }
                }
                } else {
                    Text("Hole not found")
                        .foregroundColor(Color(hex: "#2C3E50"))
                }
            }
        }
    }
    
    func deleteHole() {
        if let tripIndex = store.trips.firstIndex(where: { $0.id == tripId }) {
            store.trips[tripIndex].holes.removeAll { $0.id == holeId }
        }
        dismiss()
    }
}
