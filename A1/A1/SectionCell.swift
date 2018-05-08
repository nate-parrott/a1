//
//  SectionedArticleSectionView.swift
//  A1
//
//  Created by Nate Parrott on 5/6/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import UIKit

class SectionCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    override init(frame: CGRect){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: frame)
        
        contentView.addSubview(label)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.alpha = 0.5
        
        contentView.addSubview(collectionView)
        collectionView.register(BigImageArticleCell.self, forCellWithReuseIdentifier: "article")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.white
        collectionView.clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var section: SectionedArticleView.Section? {
        didSet {
            collectionView.reloadData()
            guard let section = section else { return }
            label.text = section.title.uppercased()
        }
    }
    var onTapArticle: ((API.Article) -> ())?
    
    // MARK: Views
    let label = UILabel()
    let collectionView: UICollectionView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let spacing = Styling.collectionPadding
        let nextCellPeek: CGFloat = Styling.collectionPadding
        
        let labelHorizontalMargin = spacing + nextCellPeek
        let labelAvailableWidth = bounds.width - labelHorizontalMargin * 2
        let height = label.sizeThatFits(CGSize(width: labelAvailableWidth, height: bounds.height)).height
        label.frame = CGRect(x: labelHorizontalMargin, y: Styling.collectionPadding, width: bounds.width - labelHorizontalMargin * 2, height: height)
        
        collectionView.frame = CGRect(x: 0, y: label.frame.maxY, width: bounds.width, height: bounds.height - label.frame.maxY)
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: bounds.width - spacing * 2 - nextCellPeek * 2, height: bounds.height - label.frame.maxY - Styling.collectionPadding * 2)
        layout.sectionInset = UIEdgeInsetsMake(Styling.collectionPadding, nextCellPeek + spacing, Styling.collectionPadding, nextCellPeek + spacing)
        layout.minimumInteritemSpacing = spacing
    }
    
    // MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.section?.articles.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "article", for: indexPath) as! BigImageArticleCell
        cell.article = section!.articles[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onTapArticle?(section!.articles[indexPath.item])
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let nArticles = section?.articles.count ?? 0
        let pageLength = (layout.itemSize.width + layout.minimumInteritemSpacing)
        let page = max(0, min(CGFloat(nArticles), round(targetContentOffset.pointee.x / pageLength)))
        targetContentOffset.pointee.x = page * pageLength
    }
}
