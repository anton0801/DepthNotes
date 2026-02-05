
import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    
    let pages = [
        OnboardingPage(
            icon: "ruler.fill",
            title: "Log Depth",
            description: "Save depth and hole details",
            color: "#FF8C42",
            gradient: ["#FF8C42", "#FF6B35"]
        ),
        OnboardingPage(
            icon: "note.text",
            title: "Notes & Bait",
            description: "Keep bait and notes together",
            color: "#FFD93D",
            gradient: ["#FFD93D", "#FFA500"]
        ),
        OnboardingPage(
            icon: "chart.bar.fill",
            title: "Compare Spots",
            description: "Find your best depths",
            color: "#4A90E2",
            gradient: ["#4A90E2", "#357ABD"]
        )
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#FFF5EB"), Color(hex: "#FFE5CC")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 450)
                
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ?
                                  LinearGradient(colors: [Color(hex: "#FF8C42"), Color(hex: "#FF6B35")], startPoint: .leading, endPoint: .trailing) :
                                  LinearGradient(colors: [Color(hex: "#2C3E50").opacity(0.3), Color(hex: "#2C3E50").opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 15) {
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            finishOnboarding()
                        }
                        .foregroundColor(Color(hex: "#2C3E50").opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#2C3E50").opacity(0.08))
                        .cornerRadius(16)
                        .font(.system(size: 17, weight: .semibold))
                    }
                    
                    Button(currentPage == pages.count - 1 ? "Get Started" : "Continue") {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            finishOnboarding()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#FF8C42"), Color(hex: "#FF6B35")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .font(.system(size: 17, weight: .semibold))
                    .shadow(color: Color(hex: "#FF8C42").opacity(0.4), radius: 12, x: 0, y: 4)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
    
    func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        withAnimation(.easeInOut(duration: 0.5)) {
            showOnboarding = false
        }
    }
}
