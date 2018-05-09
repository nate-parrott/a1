import UIKit
import WebKit
import SafariServices

class ArticleViewController: SwipeAwayViewController, WKNavigationDelegate {
    var article: API.Article!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: view.bounds)
        contentView.addSubview(webView)
        guard let urlString = article.amp_url, let url = URL(string: urlString) else { return }
        webView.navigationDelegate = self
        webView.load(URLRequest(url: url))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = contentView.bounds
    }
    
    var webView: WKWebView!
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated || navigationAction.navigationType == .formSubmitted {
            if let url = navigationAction.request.url {
                present(SFSafariViewController(url: url), animated: true, completion: nil)
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let _ = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        return webView.scrollView.contentSize.width > webView.scrollView.bounds.width
    }
}
