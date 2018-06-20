//
//  SectionedArticleSectionView.swift
//  A1
//
//  Created by Nate Parrott on 5/6/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import UIKit

class SectionCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
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
        collectionView.alwaysBounceHorizontal = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var section: SectionedArticleView.Section? {
        willSet(val) {
            if section?.title != val?.title {
                collectionView.contentOffset = .zero
            }
        }
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
        collectionView.delaysContentTouches = false
        
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
        let article = section!.articles[indexPath.item]
        preloadArticleForImminentDisplay(section!.articles[indexPath.item])
        cell.model = BigImageArticleCell.Model(article: article, showURL: section!.shouldDisplayURLs)
        cell.onTap = { [weak self] in
            guard let `self` = self else { return }
            self.onTapArticle?(article)
        }
        return cell
    }
    
    var _pageAtStartOfSwipe: Int?
    var pageLength: CGFloat {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        return (layout.itemSize.width + layout.minimumInteritemSpacing)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _pageAtStartOfSwipe = Int(round(scrollView.contentOffset.x / pageLength))
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        // what page are we currently on?
        var page = Int(round(scrollView.contentOffset.x / pageLength))
        // are we swiping?
        if velocity.x > 0 {
            page += 1
        } else if velocity.x < 0 {
            page -= 1
        }
        let minPage = max(0, _pageAtStartOfSwipe! - 1)
        let nArticles = section?.articles.count ?? 0
        let maxPage = min(max(0, nArticles - 1), _pageAtStartOfSwipe! + 1)
        page = max(minPage, min(maxPage, page))
        targetContentOffset.pointee.x = CGFloat(page) * pageLength
    }
    // MARK: Prefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let `section` = section else { return }
        // kick off an image prefetch:
        for idx in indexPaths {
            preloadArticleForImminentDisplay(section.articles[idx.item])
        }
    }
}
