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
        
        layer.shadowColor = UIColor(white: 0.1, alpha: 1).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 20
        
        addSubview(clippedContainer)
        clippedContainer.layer.cornerRadius = 16
        clippedContainer.clipsToBounds = true
        
        webView.isUserInteractionEnabled = false
        clippedContainer.addSubview(webView)
        
        title.backgroundColor = UIColor(white: 1, alpha: 0.9)
        title.font = UIFont.boldSystemFont(ofSize: 14)
        title.textAlignment = .center
        title.textColor = UIColor(white: 0.1, alpha: 1)
        clippedContainer.addSubview(title)
    }
    
    let clippedContainer = UIView()
    let webView = WKWebView(frame: .zero)
    let title = UILabel()
    
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
            title.text = a.title
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        clippedContainer.frame = bounds
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: clippedContainer.layer.cornerRadius).cgPath
        title.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 24)
        webView.frame = bounds
    }
}
