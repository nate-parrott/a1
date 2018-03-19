//
//  ArticleCell.swift
//  A1
//
//  Created by Nate Parrott on 3/19/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import UIKit

class ArticleCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.text = "hey!"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        layer.cornerRadius = 16
        layer.shadowColor = UIColor(white: 0.1, alpha: 1).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 20
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let label = UILabel()
    var article: API.Article?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 0, y: 10, width: 100, height: 50)
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
}
