import SwiftUI
import WebKit
import Combine

struct TripDetailView: View {
    let tripId: UUID
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var showAddHole = false
    @State private var selectedHole: Hole?
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#FFF5EB"), Color(hex: "#FFE5CC")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if let trip = store.trips.first(where: { $0.id == tripId }) {
                VStack(spacing: 0) {
                    // Stats Header
                    HStack(spacing: 12) {
                        StatBox(title: "Holes", value: "\(trip.holes.count)", icon: "circle.fill", gradient: ["#FF8C42", "#FF6B35"])
                        StatBox(title: "Avg Depth", value: String(format: "%.1fm", trip.avgDepth), icon: "ruler.fill", gradient: ["#FFD93D", "#FFA500"])
                        StatBox(title: "Catch", value: "\(trip.totalCatch)", icon: "fish.fill", gradient: ["#6BCF9D", "#3A9B7A"])
                    }
                    .padding()
                    
                    if trip.holes.isEmpty {
                        EmptyStateView(
                            icon: "circle.fill",
                            title: "No holes yet",
                            description: "Add your first hole"
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(trip.holes) { hole in
                                    Button(action: { selectedHole = hole }) {
                                        HoleCard(hole: hole)
                                    }
                                    .buttonStyle(CardButtonStyle())
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            withAnimation {
                                                if let tripIndex = store.trips.firstIndex(where: { $0.id == tripId }) {
                                                    store.trips[tripIndex].holes.removeAll { $0.id == hole.id }
                                                }
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle(trip.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button(role: .destructive, action: {
                                store.deleteTrip(trip)
                                dismiss()
                            }) {
                                Label("Delete Trip", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(Color(hex: "#2C3E50"))
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showAddHole = true }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#FF8C42"), Color(hex: "#FF6B35")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)
                                    .shadow(color: Color(hex: "#FF8C42").opacity(0.4), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .sheet(isPresented: $showAddHole) {
                    HoleEditorView(tripId: tripId)
                        .environmentObject(store)
                }
                .sheet(item: $selectedHole) { hole in
                    HoleDetailView(tripId: tripId, holeId: hole.id)
                        .environmentObject(store)
                }
            } else {
                Text("Trip not found")
                    .foregroundColor(Color(hex: "#2C3E50"))
            }
        }
    }
}

struct DepthWebView: View {
    @State private var targetURL: String? = ""
    @State private var isReady = false
    
    var body: some View {
        ZStack {
            if isReady, let urlString = targetURL, let url = URL(string: urlString) {
                WebViewContainer(url: url).ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { initialize() }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LoadTempURL"))) { _ in reload() }
    }
    
    private func initialize() {
        let temp = UserDefaults.standard.string(forKey: "temp_url")
        let stored = UserDefaults.standard.string(forKey: "dn_endpoint_target") ?? ""
        targetURL = temp ?? stored
        isReady = true
        if temp != nil { UserDefaults.standard.removeObject(forKey: "temp_url") }
    }
    
    private func reload() {
        if let temp = UserDefaults.standard.string(forKey: "temp_url"), !temp.isEmpty {
            isReady = false
            targetURL = temp
            UserDefaults.standard.removeObject(forKey: "temp_url")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { isReady = true }
        }
    }
}

struct WebViewContainer: UIViewRepresentable {
    let url: URL
    
    func makeCoordinator() -> WebDelegate { WebDelegate() }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = buildWebView(delegate: context.coordinator)
        context.coordinator.webView = webView
        context.coordinator.loadURL(url, in: webView)
        Task { await context.coordinator.loadCookies(in: webView) }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    private func buildWebView(delegate: WebDelegate) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.processPool = WKProcessPool()
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = preferences
        
        let contentController = WKUserContentController()
        let script = WKUserScript(
            source: """
            (function() {
                const meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                document.head.appendChild(meta);
                const style = document.createElement('style');
                style.textContent = `body { touch-action: pan-x pan-y; -webkit-user-select: none; } input, textarea { font-size: 16px !important; }`;
                document.head.appendChild(style);
                document.addEventListener('gesturestart', e => e.preventDefault());
                document.addEventListener('gesturechange', e => e.preventDefault());
            })();
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        contentController.addUserScript(script)
        config.userContentController = contentController
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let pagePrefs = WKWebpagePreferences()
        pagePrefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = pagePrefs
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.bounces = false
        webView.scrollView.bouncesZoom = false
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = delegate
        webView.uiDelegate = delegate
        return webView
    }
}

final class WebDelegate: NSObject {
    weak var webView: WKWebView?
    
    private var hops = 0
    private var maxHops = 70
    private var lastURL: URL?
    private var urlHistory: [URL] = []
    private var checkpoint: URL?
    private var popups: [WKWebView] = []
    private let cookieStorage = "depth_cookies"
    
    func loadURL(_ url: URL, in webView: WKWebView) {
        print("📝 [Depth] Load: \(url.absoluteString)")
        urlHistory = [url]
        hops = 0
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        webView.load(request)
    }
    
    func loadCookies(in webView: WKWebView) {
        guard let data = UserDefaults.standard.object(forKey: cookieStorage) as? [String: [String: [HTTPCookiePropertyKey: AnyObject]]] else { return }
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        let cookies = data.values.flatMap { $0.values }.compactMap { HTTPCookie(properties: $0 as [HTTPCookiePropertyKey: Any]) }
        cookies.forEach { cookieStore.setCookie($0) }
    }
    
    func saveCookies(from webView: WKWebView) {
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies { [weak self] cookies in
            guard let self = self else { return }
            var data: [String: [String: [HTTPCookiePropertyKey: Any]]] = [:]
            for cookie in cookies {
                var domain = data[cookie.domain] ?? [:]
                if let props = cookie.properties { domain[cookie.name] = props }
                data[cookie.domain] = domain
            }
            UserDefaults.standard.set(data, forKey: self.cookieStorage)
        }
    }
}

extension WebDelegate: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        lastURL = url
        if canNavigate(url) {
            decisionHandler(.allow)
        } else {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
        }
    }
    
    private func canNavigate(_ url: URL) -> Bool {
        let scheme = (url.scheme ?? "").lowercased()
        let path = url.absoluteString.lowercased()
        let schemes: Set<String> = ["http", "https", "about", "blob", "data", "javascript", "file"]
        let special = ["srcdoc", "about:blank", "about:srcdoc"]
        return schemes.contains(scheme) || special.contains { path.hasPrefix($0) } || path == "about:blank"
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        hops += 1
        if hops > maxHops {
            webView.stopLoading()
            if let recovery = lastURL { webView.load(URLRequest(url: recovery)) }
            hops = 0
            return
        }
        lastURL = webView.url
        saveCookies(from: webView)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let current = webView.url {
            checkpoint = current
            print("✅ [Depth] Commit: \(current.absoluteString)")
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let current = webView.url { checkpoint = current }
        hops = 0
        saveCookies(from: webView)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let code = (error as NSError).code
        if code == NSURLErrorHTTPTooManyRedirects, let recovery = lastURL {
            webView.load(URLRequest(url: recovery))
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

extension WebDelegate: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard navigationAction.targetFrame == nil else { return nil }
        let popup = WKWebView(frame: webView.bounds, configuration: configuration)
        popup.navigationDelegate = self
        popup.uiDelegate = self
        popup.allowsBackForwardNavigationGestures = true
        webView.addSubview(popup)
        popup.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popup.topAnchor.constraint(equalTo: webView.topAnchor),
            popup.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
            popup.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            popup.trailingAnchor.constraint(equalTo: webView.trailingAnchor)
        ])
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(closePopup(_:)))
        gesture.edges = .left
        popup.addGestureRecognizer(gesture)
        popups.append(popup)
        if let url = navigationAction.request.url, url.absoluteString != "about:blank" {
            popup.load(navigationAction.request)
        }
        return popup
    }
    
    @objc private func closePopup(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        if let last = popups.last {
            last.removeFromSuperview()
            popups.removeLast()
        } else {
            webView?.goBack()
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
