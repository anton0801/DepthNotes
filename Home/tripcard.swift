
import SwiftUI

struct TripCard: View {
    let trip: Trip
    @State private var appear = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon with gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: statusGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: statusGradient[0].opacity(0.4), radius: 8, x: 0, y: 4)
                
                Image(systemName: "fish.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(trip.name)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(Color(hex: "#2C3E50"))
                
                Text(trip.place)
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "#2C3E50").opacity(0.6))
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "ruler.fill")
                            .font(.system(size: 11))
                        Text("\(String(format: "%.1f", trip.avgDepth))m")
                            .font(.system(size: 13, weight: .medium))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "fish.fill")
                            .font(.system(size: 11))
                        Text("\(trip.totalCatch)")
                            .font(.system(size: 13, weight: .medium))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 11))
                        Text("\(trip.holes.count)")
                            .font(.system(size: 13, weight: .medium))
                    }
                }
                .foregroundColor(Color(hex: "#FF8C42"))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "#2C3E50").opacity(0.3))
                .font(.system(size: 14, weight: .bold))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#FF8C42").opacity(0.2), Color(hex: "#FF8C42").opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color(hex: "#FF8C42").opacity(0.15), radius: 10, x: 0, y: 5)
        )
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appear = true
            }
        }
    }
    
    var statusGradient: [Color] {
        let avgBite = trip.holes.isEmpty ? 0 : trip.holes.map { $0.biteScore }.reduce(0, +) / trip.holes.count
        if avgBite >= 4 { return [Color(hex: "#6BCF9D"), Color(hex: "#3A9B7A")] }
        if avgBite >= 2 { return [Color(hex: "#FFD93D"), Color(hex: "#FFA500")] }
        return [Color(hex: "#FF6B6B"), Color(hex: "#C74444")]
    }
}
