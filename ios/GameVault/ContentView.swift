import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        WebView()
            .ignoresSafeArea(.all)
            .statusBarHidden(true)
            .persistentSystemOverlays(.hidden)
    }
}

struct WebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)
        webView.navigationDelegate = context.coordinator

        // Load the web bundle from app resources
        if let bundlePath = Bundle.main.resourcePath,
           let indexPath = Bundle.main.path(forResource: "web/index", ofType: "html") {
            let baseURL = URL(fileURLWithPath: bundlePath + "/web")
            let indexURL = URL(fileURLWithPath: indexPath)
            webView.loadFileURL(indexURL, allowingReadAccessTo: baseURL)
        }

        // Enable gesture recognizers for fullscreen
        webView.allowsBackForwardNavigationGestures = true

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No-op: content is static after load
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            // Open external URLs in Safari
            if navigationAction.navigationType == .linkActivated,
               let url = navigationAction.request.url,
               url.scheme?.hasPrefix("http") == true {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}
