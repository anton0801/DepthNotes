
import SwiftUI

struct HoleEditorView: View {
    let tripId: UUID
    let editingHoleId: UUID?
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var number: Int = 1
    @State private var depth = 3.0
    @State private var bottomType = BottomType.sand
    @State private var bait = ""
    @State private var biteScore = 3
    @State private var catchCount = 0
    
    init(tripId: UUID, holeId: UUID? = nil) {
        self.tripId = tripId
        self.editingHoleId = holeId
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#FFF5EB"), Color(hex: "#FFE5CC")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Basics
                        SectionCard(title: "Basics") {
                            VStack(spacing: 18) {
                                HStack {
                                    Text("Hole #")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(Color(hex: "#2C3E50").opacity(0.8))
                                    Spacer()
                                    HStack(spacing: 12) {
                                        Button(action: { if number > 1 { number -= 1 } }) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.system(size: 28))
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [Color(hex: "#FF8C42"), Color(hex: "#FF6B35")],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        }
                                        
                                        Text("\(number)")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(Color(hex: "#2C3E50"))
                                            .frame(width: 50)
                                        
                                        Button(action: { number += 1 }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 28))
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [Color(hex: "#FF8C42"), Color(hex: "#FF6B35")],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        }
                                    }
                                }
                                
                                Divider().background(Color(hex: "#2C3E50").opacity(0.1))
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Depth")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(Color(hex: "#2C3E50").opacity(0.8))
                                        Spacer()
                                        Text(String(format: "%.1f m", depth))
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [Color(hex: "#FF8C42"), Color(hex: "#FF6B35")],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    }
                                    
                                    Slider(value: $depth, in: 0...20, step: 0.1)
                                        .accentColor(Color(hex: "#FF8C42"))
                                }
                                
                                Divider().background(Color(hex: "#2C3E50").opacity(0.1))
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Bottom Type")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(Color(hex: "#2C3E50").opacity(0.8))
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(BottomType.allCases, id: \.self) { type in
                                                Button(action: {
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                        bottomType = type
                                                    }
                                                }) {
                                                    HStack(spacing: 6) {
                                                        Text(type.icon)
                                                            .font(.system(size: 16))
                                                        Text(type.rawValue)
                                                            .font(.system(size: 14, weight: .medium))
                                                    }
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 10)
                                                    .background(
                                                        Group {
                                                            if bottomType == type {
                                                                RoundedRectangle(cornerRadius: 20)
                                                                    .fill(
                                                                        LinearGradient(
                                                                            colors: [Color(hex: "#FF8C42"), Color(hex: "#FF6B35")],
                                                                            startPoint: .leading,
                                                                            endPoint: .trailing
                                                                        )
                                                                    )
                                                                    .shadow(color: Color(hex: "#FF8C42").opacity(0.4), radius: 8, x: 0, y: 4)
                                                            } else {
                                                                RoundedRectangle(cornerRadius: 20)
                                                                    .fill(Color(hex: "#2C3E50").opacity(0.08))
                                                                    .overlay(
                                                                        RoundedRectangle(cornerRadius: 20)
                                                                            .stroke(Color(hex: "#2C3E50").opacity(0.1), lineWidth: 1)
                                                                    )
                                                            }
                                                        }
                                                    )
                                                    .foregroundColor(bottomType == type ? .white : Color(hex: "#2C3E50"))
                                                }
                                                .scaleEffect(bottomType == type ? 1.05 : 1.0)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        fishingDetailsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Hole")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#2C3E50").opacity(0.7))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHole()
                    }
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color(hex: "#FF8C42"))
                }
            }
            .onAppear {
                loadHoleData()
            }
        }
    }
    
    private var fishingDetailsSection: some View {
        SectionCard(title: "Fishing Details") {
            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Bait/Lure")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: "#2C3E50").opacity(0.8))
                    TextField("e.g. Jig, Minnow", text: $bait)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "#FF8C42").opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: Color(hex: "#FF8C42").opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                        .foregroundColor(Color(hex: "#2C3E50"))
                        .accentColor(Color(hex: "#FF8C42"))
                }
                
                Divider().background(Color(hex: "#2C3E50").opacity(0.1))
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Bite Score")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: "#2C3E50").opacity(0.8))
                    
                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { score in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    biteScore = score
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            biteScore >= score ?
                                            LinearGradient(
                                                colors: [Color(hex: "#FFD93D"), Color(hex: "#FFA500")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ) :
                                            LinearGradient(
                                                colors: [Color(hex: "#2C3E50").opacity(0.08), Color(hex: "#2C3E50").opacity(0.08)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 50, height: 50)
                                        .shadow(color: biteScore >= score ? Color(hex: "#FFD93D").opacity(0.4) : Color.clear, radius: 8, x: 0, y: 4)
                                    
                                    Text("\(score)")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(biteScore >= score ? .white : Color(hex: "#2C3E50").opacity(0.4))
                                }
                            }
                            .scaleEffect(biteScore == score ? 1.15 : 1.0)
                        }
                    }
                }
                
                Divider().background(Color(hex: "#2C3E50").opacity(0.1))
                
                HStack {
                    Text("Catch Count")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: "#2C3E50").opacity(0.8))
                    Spacer()
                    HStack(spacing: 12) {
                        Button(action: { if catchCount > 0 { catchCount -= 1 } }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "#6BCF9D"), Color(hex: "#3A9B7A")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        Text("\(catchCount)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "#2C3E50"))
                            .frame(width: 50)
                        
                        Button(action: { catchCount += 1 }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "#6BCF9D"), Color(hex: "#3A9B7A")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                }
            }
        }
    }
    
    private func loadHoleData() {
        if let tripIndex = store.trips.firstIndex(where: { $0.id == tripId }) {
            let trip = store.trips[tripIndex]
            
            if let holeId = editingHoleId,
               let hole = trip.holes.first(where: { $0.id == holeId }) {
                // Editing existing hole
                number = hole.number
                depth = hole.depth
                bottomType = hole.bottomType
                bait = hole.bait
                biteScore = hole.biteScore
                catchCount = hole.catchCount
            } else {
                // New hole
                number = (trip.holes.map { $0.number }.max() ?? 0) + 1
            }
        }
    }
    
    private func saveHole() {
        let holeId: UUID
        if let editingHoleId = editingHoleId,
           let tripIndex = store.trips.firstIndex(where: { $0.id == tripId }),
           let existingHole = store.trips[tripIndex].holes.first(where: { $0.id == editingHoleId }) {
            holeId = existingHole.id
        } else {
            holeId = UUID()
        }
        
        let hole = Hole(
            id: holeId,
            number: number,
            depth: depth,
            bottomType: bottomType,
            bait: bait,
            biteScore: biteScore,
            catchCount: catchCount,
            species: [],
            notes: ""
        )
        
        if let tripIndex = store.trips.firstIndex(where: { $0.id == tripId }) {
            if let editingHoleId = editingHoleId,
               let holeIndex = store.trips[tripIndex].holes.firstIndex(where: { $0.id == editingHoleId }) {
                store.trips[tripIndex].holes[holeIndex] = hole
            } else {
                store.trips[tripIndex].holes.append(hole)
            }
        }
        
        dismiss()
    }
}
