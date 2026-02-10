import SwiftUI
import Combine

#Preview {
    DepthNotificationView(store: Store())
}

struct DepthNotesSplashScreen: View {
    @State private var animateLogo = false
    @State private var animateWaves = false
    @State private var animateText = false
    @State private var animateParticles = false
    @StateObject private var store = Store()
    @State private var showLoader = false
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var waveOffset1: CGFloat = 0
    @State private var waveOffset2: CGFloat = 0
    @State private var waveOffset3: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Deep ocean gradient background
                LinearGradient(
                    colors: [
                        Color(hex: "0A1128"),
                        Color(hex: "001F54"),
                        Color(hex: "034078"),
                        Color(hex: "0A1128")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Animated water waves
                WaveLayer(offset: waveOffset1, opacity: 0.1, speed: 3.0)
                WaveLayer(offset: waveOffset2, opacity: 0.15, speed: 4.0)
                WaveLayer(offset: waveOffset3, opacity: 0.2, speed: 5.0)
                
                // Floating particles
                if animateParticles {
                    ForEach(0..<40, id: \.self) { index in
                        FloatingBubble(index: index)
                    }
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Main content
                    mainContent
                    
                    Spacer()
                    
                    // Loader section
                    loaderSection
                        .padding(.bottom, 80)
                }
                
                NavigationLink(destination: DepthWebView().navigationBarBackButtonHidden(true), isActive: $store.state.ui.navigateWeb) {
                    EmptyView()
                }

                NavigationLink(
                    destination: ContentView().navigationBarBackButtonHidden(true),
                    isActive: $store.state.ui.navigateMain
                ) {
                    EmptyView()
                }
            }
            .onAppear {
                startAnimations()
                // store.dispatch(.initialize)
                setupEvents()
            }
            .fullScreenCover(isPresented: $store.state.ui.showNotificationPrompt) {
                DepthNotificationView(store: store)
            }

            .fullScreenCover(isPresented: $store.state.ui.showOfflineView) {
                UnavailableView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    @State private var events = Set<AnyCancellable>()
    
    private func setupEvents() {
        NotificationCenter.default.publisher(for: Notification.Name("ConversionDataReceived"))
            .compactMap { $0.userInfo?["conversionData"] as? [String: Any] }
            .sink { store.dispatch(.trackingReceived($0)) }
            .store(in: &events)
        
        NotificationCenter.default.publisher(for: Notification.Name("deeplink_values"))
            .compactMap { $0.userInfo?["deeplinksData"] as? [String: Any] }
            .sink { store.dispatch(.navigationReceived($0)) }
            .store(in: &events)
    }
    
    // MARK: - Main Content
    var mainContent: some View {
        VStack(spacing: 40) {
            // Logo with depth effect
            logoSection
            
            // App title
            titleSection
        }
    }
    
    var logoSection: some View {
        ZStack {
            // Outer ripple rings
            ForEach(0..<4) { ring in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "1282A2").opacity(0.6),
                                Color(hex: "1282A2").opacity(0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 180 + CGFloat(ring * 40), height: 180 + CGFloat(ring * 40))
                    .scaleEffect(animateLogo ? 1.3 : 0.7)
                    .opacity(animateLogo ? 0 : 0.8)
                    .animation(
                        Animation.easeOut(duration: 2.0)
                            .delay(Double(ring) * 0.15)
                            .repeatForever(autoreverses: false),
                        value: animateLogo
                    )
            }
            
            // Main glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "1282A2").opacity(0.4),
                            Color(hex: "1282A2").opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .blur(radius: 30)
                .scaleEffect(pulseScale)
            
            // Logo container
            ZStack {
                // Background circle with depth
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "034078").opacity(0.9),
                                Color(hex: "001F54").opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 180, height: 180)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "1282A2").opacity(0.8),
                                        Color(hex: "FEFCFB").opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 4
                            )
                    )
                    .shadow(color: Color(hex: "1282A2").opacity(0.6), radius: 40, x: 0, y: 15)
                
                // Inner layer
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "001F54").opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 140)
                
                // Main icon - document with depth lines
                VStack(spacing: 8) {
                    ZStack {
                        // Document icon
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 70, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FEFCFB"),
                                        Color(hex: "1282A2")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(hex: "1282A2").opacity(0.8), radius: 15, x: 0, y: 5)
                        
                        // Depth indicator
                        Image(systemName: "arrow.down.to.line")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "1282A2"))
                            .offset(y: -5)
                    }
                }
                .rotationEffect(.degrees(rotationAngle))
            }
            .scaleEffect(animateLogo ? 1 : 0.3)
            .opacity(animateLogo ? 1 : 0)
        }
    }
    
    var titleSection: some View {
        VStack(spacing: 20) {
            // Main title with depth effect
            ZStack {
                // Shadow layer
                Text("DEPTH NOTES")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "1282A2").opacity(0.5))
                    .blur(radius: 10)
                    .offset(y: 4)
                
                // Main text with gradient
                Text("DEPTH NOTES")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "FEFCFB"),
                                Color(hex: "1282A2"),
                                Color(hex: "FEFCFB")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        // Shimmer effect
                        GeometryReader { geometry in
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0),
                                    Color.white.opacity(0.9),
                                    Color.white.opacity(0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: 80)
                            .offset(x: animateText ? geometry.size.width + 80 : -80)
                        }
                        .mask(
                            Text("DEPTH NOTES")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                        )
                    )
                    .shadow(color: Color(hex: "1282A2").opacity(0.8), radius: 20, x: 0, y: 10)
            }
            .tracking(4)
            
            // Subtitle with wave animation
            HStack(spacing: 12) {
                WaveLine()
                    .stroke(
                        Color(hex: "1282A2"),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 40, height: 10)
                    .opacity(animateText ? 1 : 0)
                
                Text("Dive Deep into Your Thoughts")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "1282A2"),
                                Color(hex: "FEFCFB").opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .tracking(2)
                
                WaveLine()
                    .stroke(
                        Color(hex: "1282A2"),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 40, height: 10)
                    .opacity(animateText ? 1 : 0)
            }
            .opacity(animateText ? 1 : 0)
            // .offset(y: animateText ? 0 : 20)
        }
    }
    
    var loaderSection: some View {
        VStack(spacing: 20) {
            // Infinite rotating loader
            InfiniteDepthLoader()
                .frame(width: 60, height: 60)
                .opacity(showLoader ? 1 : 0)
            
            // Loading text with animated dots
            HStack(spacing: 4) {
                Text("Preparing app content")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "FEFCFB").opacity(0.7))
                
                HStack(spacing: 3) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color(hex: "1282A2"))
                            .frame(width: 5, height: 5)
                            .scaleEffect(animateDot(index: index) ? 1.2 : 0.6)
                            .opacity(animateDot(index: index) ? 1 : 0.3)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: showLoader
                            )
                    }
                }
            }
            .opacity(showLoader ? 1 : 0)
        }
    }
    
    func startAnimations() {
        // Wave animations
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            waveOffset1 = UIScreen.main.bounds.width
            animateWaves = true
        }
        
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            waveOffset2 = UIScreen.main.bounds.width
        }
        
        withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
            waveOffset3 = UIScreen.main.bounds.width
        }
        
        // Logo animation
        withAnimation(.spring(response: 1.2, dampingFraction: 0.6)) {
            animateLogo = true
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.2
        }
        
        // Gentle rotation
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            animateParticles = true
        }
        
        // Text shimmer
        withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
            animateText = true
        }
        
        withAnimation(.linear(duration: 17.5).repeatForever(autoreverses: false).delay(1.0)) {
            animateText = true
        }
        
        // Show loader
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeIn(duration: 0.4)) {
                showLoader = true
            }
        }
    }
    
    func animateDot(index: Int) -> Bool {
        return showLoader
    }
}

// MARK: - Infinite Depth Loader
struct InfiniteDepthLoader: View {
    @State private var rotation: Double = 0
    @State private var scale1: CGFloat = 1.0
    @State private var scale2: CGFloat = 1.0
    @State private var scale3: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color(hex: "1282A2"),
                            Color(hex: "FEFCFB"),
                            Color(hex: "1282A2")
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale1)
            
            // Middle ring
            Circle()
                .trim(from: 0, to: 0.5)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color(hex: "FEFCFB"),
                            Color(hex: "1282A2"),
                            Color(hex: "FEFCFB")
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(-rotation * 1.5))
                .scaleEffect(scale2)
            
            // Inner ring
            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(
                    Color(hex: "1282A2"),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 20, height: 20)
                .rotationEffect(.degrees(rotation * 2))
                .scaleEffect(scale3)
            
            // Center dot
            Circle()
                .fill(Color(hex: "1282A2"))
                .frame(width: 6, height: 6)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                scale1 = 1.1
            }
            
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.2)) {
                scale2 = 1.15
            }
            
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(0.4)) {
                scale3 = 1.2
            }
        }
    }
}

// MARK: - Wave Layer
struct WaveLayer: View {
    let offset: CGFloat
    let opacity: Double
    let speed: Double
    
    var body: some View {
        WaveShape(offset: offset, percent: 0.8)
            .fill(
                LinearGradient(
                    colors: [
                        Color(hex: "1282A2").opacity(opacity),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
            .blur(radius: 5)
    }
}

struct UnavailableView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("issue_background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea()
                
                Image("issues_alert")
                    .resizable()
                    .frame(width: 300, height: 270)
            }
        }
        .ignoresSafeArea()
    }
}


struct WaveShape: Shape {
    var offset: CGFloat
    var percent: CGFloat
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let waveHeight: CGFloat = 0.03 * rect.height
        let yOffset = (1 - percent) * rect.height
        
        path.move(to: CGPoint(x: 0, y: yOffset))
        
        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / 50
            let sine = sin(relativeX + offset / 50)
            let y = yOffset + waveHeight * sine
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Wave Line for subtitle
struct WaveLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / 10
            let sine = sin(relativeX) * (height / 4)
            path.addLine(to: CGPoint(x: x, y: midHeight + sine))
        }
        
        return path
    }
}

// MARK: - Floating Bubble
struct FloatingBubble: View {
    let index: Int
    @State private var yOffset: CGFloat = UIScreen.main.bounds.height + 100
    @State private var xOffset: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 1.0
    
    private let randomDelay: Double
    private let randomDuration: Double
    private let randomX: CGFloat
    private let randomSize: CGFloat
    
    init(index: Int) {
        self.index = index
        self.randomDelay = Double.random(in: 0...3)
        self.randomDuration = Double.random(in: 6...12)
        self.randomX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
        self.randomSize = CGFloat.random(in: 4...15)
    }
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color(hex: "FEFCFB").opacity(0.6),
                        Color(hex: "1282A2").opacity(0.3),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: randomSize / 2
                )
            )
            .frame(width: randomSize, height: randomSize)
            .overlay(
                Circle()
                    .stroke(Color(hex: "FEFCFB").opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(scale)
            .offset(x: xOffset, y: yOffset)
            .opacity(opacity)
            .blur(radius: 0.5)
            .onAppear {
                xOffset = randomX
                
                // Float up animation
                withAnimation(
                    Animation.linear(duration: randomDuration)
                        .delay(randomDelay)
                        .repeatForever(autoreverses: false)
                ) {
                    yOffset = -100
                }
                
                // Horizontal drift
                withAnimation(
                    Animation.easeInOut(duration: randomDuration / 2)
                        .delay(randomDelay)
                        .repeatForever(autoreverses: true)
                ) {
                    xOffset = randomX + CGFloat.random(in: -30...30)
                }
                
                // Scale animation
                withAnimation(
                    Animation.easeInOut(duration: 2)
                        .delay(randomDelay)
                        .repeatForever(autoreverses: true)
                ) {
                    scale = 1.3
                }
                
                // Fade in
                withAnimation(.easeIn(duration: 1).delay(randomDelay)) {
                    opacity = 0.8
                }
                
                // Fade out at top
                withAnimation(.easeOut(duration: 2).delay(randomDelay + randomDuration - 2)) {
                    opacity = 0
                }
            }
    }
}
