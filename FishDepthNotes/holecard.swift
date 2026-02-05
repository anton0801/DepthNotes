
import SwiftUI

struct HoleCard: View {
    let hole: Hole
    
    var body: some View {
        HStack(spacing: 16) {
            // Number Badge with gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#FF8C42"), Color(hex: "#FF6B35")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 54, height: 54)
                    .shadow(color: Color(hex: "#FF8C42").opacity(0.4), radius: 8, x: 0, y: 4)
                
                Text("#\(hole.number)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("\(String(format: "%.1f", hole.depth))m")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "#2C3E50"))
                    
                    Text(hole.bottomType.icon)
                        .font(.system(size: 16))
                    
                    Text(hole.bottomType.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#2C3E50").opacity(0.6))
                }
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "f.cursive")
                            .font(.system(size: 11))
                        Text(hole.bait)
                            .font(.system(size: 13))
                    }
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { i in
                            Image(systemName: i < hole.biteScore ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "#FFD93D"))
                        }
                    }
                    
                    if hole.catchCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "fish.fill")
                                .font(.system(size: 11))
                            Text("\(hole.catchCount)")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "#6BCF9D"))
                    }
                }
                .foregroundColor(Color(hex: "#2C3E50").opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "#2C3E50").opacity(0.3))
                .font(.system(size: 13, weight: .bold))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#FF8C42").opacity(0.2), Color(hex: "#FF8C42").opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color(hex: "#FF8C42").opacity(0.12), radius: 8, x: 0, y: 4)
        )
    }
}
