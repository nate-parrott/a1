import UIKit
import WebKit
import SafariServices

class ArticleViewController: SwipeAwayViewController, WKNavigationDelegate, ToolbarDelegate {
    var article: API.Article!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: view.bounds)
        contentView.addSubview(webView)
        guard let urlString = article.amp_url, let url = URL(string: urlString) else { return }
        webView.navigationDelegate = self
        webView.load(URLRequest(url: url))
        
        toolbar = UINib(nibName: "ToolbarView", bundle: nil).instantiate(withOwner: nil, options: nil).first! as! ToolbarView
        toolbar.delegate = self
        contentView.addSubview(toolbar)
    }
    
    var _toolbarHeight: CGFloat {
        return view.safeAreaInsets.bottom / 2 + 44
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        toolbar.frame = CGRect(x: 0, y: view.bounds.height - _toolbarHeight, width: view.bounds.width, height: _toolbarHeight)
        webView.frame = contentView.bounds
        
        var webViewInsets = webView.scrollView.contentInset
        webViewInsets.bottom = _toolbarHeight
        webView.scrollView.contentInset = webViewInsets
    }
    
    var webView: WKWebView!
    var toolbar: ToolbarView!
    
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
    
    func toolbarPressedBack(ToolbarView _: ToolbarView) {
        _induceExit()
    }
    
    func toolbarPressedShare(ToolbarView _: ToolbarView) {
        guard let urlString = article.canonical_url, let url = URL(string: urlString) else { return }
        let shareVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(shareVC, animated: true, completion: nil)
    }
}
