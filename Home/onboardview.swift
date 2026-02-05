
import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var appear = false
    @State private var iconRotate = false
    
    var body: some View {
        VStack(spacing: 35) {
            ZStack {
                // Background glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: page.color).opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 30)
                
                // Icon background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.gradient.map { Color(hex: $0) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(hex: page.color).opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: page.icon)
                    .font(.system(size: 55, weight: .semibold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(iconRotate ? 5 : -5))
            }
            .scaleEffect(appear ? 1 : 0.5)
            .opacity(appear ? 1 : 0)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "#2C3E50"))
                
                Text(page.description)
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#2C3E50").opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 30)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.1)) {
                appear = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                iconRotate.toggle()
            }
        }
    }
}
