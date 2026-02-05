
import SwiftUI

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [String]
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient.map { Color(hex: $0) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: Color(hex: gradient[0]).opacity(0.4), radius: 8, x: 0, y: 4)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "#2C3E50"))
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "#2C3E50").opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "#FF8C42").opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color(hex: "#FF8C42").opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}
