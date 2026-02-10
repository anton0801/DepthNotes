import Foundation
import SwiftUI

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: String
    let gradient: [String]
}


struct DepthNotificationView: View {
    @ObservedObject var store: Store
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image("notifications_background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: g.size.width, height: g.size.height)
                    .ignoresSafeArea()
                    .opacity(0.9)
                
                if g.size.width < g.size.height {
                    VStack(spacing: 12) {
                        Spacer()
                        
                        Text("ALLOW NOTIFICATIONS ABOUT\nBONUSES AND PROMOS")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .multilineTextAlignment(.center)
                        
                        Text("STAY TUNED WITH BEST OFFERS FROM\nOUR CASINO")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 12)
                            .multilineTextAlignment(.center)
                        
                        actionButtons
                    }
                    .padding(.bottom, 24)
                } else {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 12) {
                            Spacer()
                            
                            Text("ALLOW NOTIFICATIONS ABOUT\nBONUSES AND PROMOS")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .multilineTextAlignment(.leading)
                            
                            Text("STAY TUNED WITH BEST OFFERS FROM\nOUR CASINO")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 12)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        VStack {
                            Spacer()
                            actionButtons
                        }
                        Spacer()
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 30) {
            Button {
                store.dispatch(.notificationPermissionRequested)
            } label: {
                Text("YES, I WANT BONUSES!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(
                        Color(hex: "65F0FF")
                    )
                    .cornerRadius(10)
            }
            .padding(.horizontal, 24)
            
            Button {
                store.dispatch(.notificationPromptDismissed)
            } label: {
                Text("Skip")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
    }
}
