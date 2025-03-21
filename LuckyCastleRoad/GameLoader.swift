import SwiftUI
import WebKit
import Foundation

class GameLoader_DCA97460Model: ObservableObject {
    @Published var loadingState: GameLoader = .idle
    let url: URL
    private var webView: WKWebView?
    private var progressObservation: NSKeyValueObservation?
    private var currentProgress: Double = 0.0
   
    
    init(url: URL) {
        self.url = url
        debugPrint("Model initialized with URL: \(url)")
    }
    
    func setWebView(_ webView: WKWebView) {
        self.webView = webView
        observeProgress(webView)
        loadRequest()
        debugPrint("WebView set in Model")
    }
    
    func loadRequest() {
        guard let webView = webView else {
            debugPrint("WebView is nil, cannot load yet")
            return
        }
        let request = URLRequest(url: url, timeoutInterval: 15.0)
        debugPrint("Loading request for URL: \(url)")
       
        DispatchQueue.main.async { [weak self] in
            self?.loadingState = .loading(progress: 0.0)
            self?.currentProgress = 0.0
        }
        webView.load(request)
    }
    
    private func observeProgress(_ webView: WKWebView) {
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            let progress = webView.estimatedProgress
            debugPrint("Progress updated: \(Int(progress * 100))%")
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if progress > self.currentProgress {
                    self.currentProgress = progress
                    self.loadingState = .loading(progress: self.currentProgress)
                }
                if progress >= 1.0 {
                    self.loadingState = .loaded
                }
            }
        }
    }
    
    func updateNetworkStatus(_ isConnected: Bool) {
        if isConnected && loadingState == .noInternet {
            loadRequest()
        } else if !isConnected {
            DispatchQueue.main.async { [weak self] in
                self?.loadingState = .noInternet
            }
        }
       
    }
}

enum GameLoader: Equatable {
    case idle
    case loading(progress: Double)
    case loaded
    case failed(Error)
    case noInternet
    
    static func == (lhs: GameLoader, rhs: GameLoader) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loaded, .loaded), (.noInternet, .noInternet):
            return true
        case (.loading(let lp), .loading(let rp)):
            return lp == rp
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}

struct GameLoaderRenderer: UIViewRepresentable {
    @ObservedObject var ctrl: GameLoader_DCA97460Model
    private let token = "TOKEN_DCA97460_705"
    
    func makeCoordinator() -> WebControl {
        WebControl(owner: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // Настройка для отключения кэширования
        config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        
        let view = WKWebView(frame: .zero, configuration: config)
        
        // Очистка всех существующих данных кэша
        let dataTypes = Set([WKWebsiteDataTypeDiskCache,
                           WKWebsiteDataTypeMemoryCache,
                           WKWebsiteDataTypeCookies,
                           WKWebsiteDataTypeLocalStorage])
        
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes,
                                              modifiedSince: Date.distantPast) {
            debugPrint("Cache cleared on creation")
        }
        
        debugPrint("Renderer: \(ctrl.url)")
        view.navigationDelegate = context.coordinator
        ctrl.setWebView(view)
        return view
    }
    
    func updateUIView(_ view: WKWebView, context: Context) {
        // Очистка кэша при обновлении представления
        let dataTypes = Set([WKWebsiteDataTypeDiskCache,
                           WKWebsiteDataTypeMemoryCache,
                           WKWebsiteDataTypeCookies,
                           WKWebsiteDataTypeLocalStorage])
        
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes,
                                              modifiedSince: Date.distantPast) {
            debugPrint("Cache cleared on update")
        }
        
        debugPrint("RendererUpdate: \(view.url?.absoluteString ?? "nil")")
    }
    
    class WebControl: NSObject, WKNavigationDelegate {
        let owner: GameLoaderRenderer
        var redirectFlag = false
      
        init(owner: GameLoaderRenderer) {
            self.owner = owner
            debugPrint("Control init")
        }
        
        private func updateState(_ state: GameLoader) {
            DispatchQueue.main.async { [weak self] in
                self?.owner.ctrl.loadingState = state
            }
        }
        
        func webView(_ wv: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
            debugPrint("StartNav: \(wv.url?.absoluteString ?? "n/a")")
            if !redirectFlag { updateState(.loading(progress: 0.0)) }
        }
        
        func webView(_ wv: WKWebView, didCommit _: WKNavigation!) {
            redirectFlag = false
            debugPrint("CommitNav: \(Int(wv.estimatedProgress * 100))%")
        }
        
        func webView(_ wv: WKWebView, didFinish _: WKNavigation!) {
            debugPrint("EndNav: \(wv.url?.absoluteString ?? "n/a")")
            updateState(.loaded)
        }
        
        func webView(_ wv: WKWebView, didFail _: WKNavigation!, withError e: Error) {
            debugPrint("FailNav: \(e)")
            updateState(.failed(e))
        }
        
        func webView(_ wv: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError e: Error) {
            debugPrint("ProvFailNav: \(e)")
            updateState(.failed(e))
        }
        
        func webView(_ wv: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if action.navigationType == .other && wv.url != nil {
                redirectFlag = true
                debugPrint("RedirNav: \(action.request.url?.absoluteString ?? "n/a")")
            }
            decisionHandler(.allow)
        }
    }
}

struct GameLoaderPanel: View {
    @StateObject var ctrl: GameLoader_DCA97460Model
    
    init(ctrl: GameLoader_DCA97460Model) {
        _ctrl = StateObject(wrappedValue: ctrl)
    }
    
    var body: some View {
        ZStack {
            GameLoaderRenderer(ctrl: ctrl)
            .opacity(ctrl.loadingState == .loaded ? 1 : 0.5)
            if case .loading(let p) = ctrl.loadingState {
                GeometryReader { geo in
                    LoadingScreen(progress: p)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .background(Color.black)
                }
            } else if case .failed(let e) = ctrl.loadingState {
                Text("Error: \(e.localizedDescription)").foregroundColor(.red)
            } else if case .noInternet = ctrl.loadingState {
                Text("")
            }
        }
    }
}
