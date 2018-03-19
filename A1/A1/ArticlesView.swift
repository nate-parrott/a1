//
//  ArticlesView.swift
//  A1
//
//  Created by Nate Parrott on 3/18/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import UIKit

class ArticlesView : UIView, UICollectionViewDataSource {
    // MARK: Lifecycle
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        _setupIfNeeded()
    }
    
    var _setupYet = false
    func _setupIfNeeded() {
        guard !_setupYet else { return }
        _setupYet = true
        backgroundColor = UIColor.black
        addSubview(collectionView)
        collectionView.register(ArticleCell.self, forCellWithReuseIdentifier: "article")
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
        var a = [API.Article]()
        while a.count < 20 {
            a.append(API.Article())
        }
        articles = a
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = UIEdgeInsetsInsetRect(bounds, safeAreaInsets)
    }
    
    // MARK: Data
    
    var articles = [API.Article]() {
        didSet {
            _setupIfNeeded()
            collectionView.reloadData()
        }
    }
    
    // MARK: CollectionView
    
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: RolodexLayout())
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "article", for: indexPath) as! ArticleCell
        cell.article = articles[indexPath.item]
        let white = fmod(CGFloat(indexPath.item) * 0.30, 0.8) + 0.2
        cell.backgroundColor = UIColor(white: white, alpha: 1)
        return cell
    }
}
