
import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    @State private var pulse = false
    @State private var rotate = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#FF8C42").opacity(0.2), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 20)
                    .scaleEffect(pulse ? 1.1 : 1.0)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#FF8C42").opacity(0.3), Color(hex: "#FF6B35").opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#FF8C42"), Color(hex: "#FF6B35")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .rotationEffect(.degrees(rotate ? 5 : -5))
            }
            
            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "#2C3E50"))
                
                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#2C3E50").opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulse = true
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                rotate = true
            }
        }
    }
}
