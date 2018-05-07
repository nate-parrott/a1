//
//  SectionedArticleSectionView.swift
//  A1
//
//  Created by Nate Parrott on 5/6/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import UIKit

class SectionCell: UICollectionViewCell {
    override init(frame: CGRect){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: frame)
        
        contentView.addSubview(label)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.alpha = 0.5
        
        contentView.addSubview(collectionView)
        collectionView.backgroundColor = UIColor(white: 0, alpha: 0.1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var section: SectionedArticleView.Section? {
        didSet {
            guard let section = section else { return }
            label.text = section.title.uppercased()
        }
    }
    
    // MARK: Views
    let label = UILabel()
    let collectionView: UICollectionView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let padding = Styling.collectionPadding
        
        let height = label.sizeThatFits(bounds.size).height
        label.frame = CGRect(x: padding, y: padding, width: bounds.width - padding * 2, height: height)
        collectionView.frame = CGRect(x: 0, y: label.frame.maxY, width: bounds.width, height: bounds.height - label.frame.maxY)
    }
}
