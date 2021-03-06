//
//  SectionedArticleView.swift
//  A1
//
//  Created by Nate Parrott on 5/6/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import UIKit

class SectionedArticleView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    override init(frame: CGRect) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        super.init(frame: frame)
        
        addSubview(collectionView)
        collectionView.backgroundColor = UIColor.white
        
        collectionView.register(SectionCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: CollectionView
    let collectionView: UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SectionCell
        cell.section = sections[indexPath.item]
        cell.onTapArticle = { [weak self] (article) in
            self?.onTapArticle?(article)
        }
        return cell
    }
    
    // MARK: Data
    struct Section {
        let title: String
        let articles: [API.Article]
        var shouldDisplayURLs: Bool {
            let allHostnames = Set(articles.compactMap({ $0.canonical_url }).compactMap({ URL(string: $0) }).compactMap({ $0.host }))
            return allHostnames.count > 1
        }
    }
    var sections = [Section]() {
        didSet {
            collectionView.reloadData()
            // Trigger low-priority preloading of all items:
            let sections = self.sections
            PreloadingHelpers.queue.async {
                self._preloadables = createFullContentPreloadables(sections: sections)
            }
        }
    }
    var _preloadables = [Loadable]() {
        didSet(old) {
            for newItem in _preloadables {
                RequestManager.shared.load(newItem)
            }
            for item in old {
                RequestManager.shared.cancel(item)
            }
        }
    }
    var onTapArticle: ((API.Article) -> ())?
    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(Styling.collectionPadding, 0, Styling.collectionPadding, 0)
        layout.itemSize = CGSize(width: bounds.width, height: round(bounds.width / 1.61803398875))
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
    }
}
