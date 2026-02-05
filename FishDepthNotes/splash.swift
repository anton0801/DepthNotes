
import SwiftUI

struct SplashScreen: View {
    @State private var scale: CGFloat = 0.95
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#FFF5EB"), Color(hex: "#FFE5CC"), Color(hex: "#FFD4A3")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                ZStack {
                    // Outer glow circles
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "#FF8C42").opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "#FF8C42").opacity(0.2), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "ruler.fill")
                        .font(.system(size: 55))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#FF8C42"), Color(hex: "#FF6B35")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .rotationEffect(.degrees(rotation))
                    
                    Image(systemName: "fish.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#4A90E2"), Color(hex: "#357ABD")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .offset(x: 30, y: -30)
                        .shadow(color: Color(hex: "#4A90E2").opacity(0.6), radius: 10)
                }
                
                VStack(spacing: 8) {
                    Text("Depth")
                        .font(.system(size: 38, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#2C3E50"), Color(hex: "#FF8C42")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Notes +")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(Color(hex: "#2C3E50").opacity(0.7))
                        .tracking(3)
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}
