//
//  ArticleCell.swift
//  A1
//
//  Created by Nate Parrott on 3/19/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import UIKit
import WebKit

class ArticleCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 16
        layer.shadowColor = UIColor(white: 0.1, alpha: 1).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 20
        
        webView.layer.cornerRadius = layer.cornerRadius
        webView.isUserInteractionEnabled = false
        contentView.addSubview(webView)
    }
    
    let webView = WKWebView(frame: .zero)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var article: API.Article? {
        didSet {
            guard let a = article else { return }
            webView.stopLoading()
            webView.loadHTMLString("", baseURL: nil)
            guard let urlString = a.amp_url, let url = URL(string: urlString) else { return }
            webView.load(URLRequest(url: url))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        webView.frame = bounds
    }
}
