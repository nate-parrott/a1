//
//  RolodexView.swift
//  A1
//
//  Created by Nate Parrott on 3/18/18.
//  Copyright © 2018 Nate Parrott. All rights reserved.
//

import UIKit

class RolodexLayout : UICollectionViewLayout {
    // assumes the CollectionView has a single section
    
    override func prepare() {
        super.prepare()
        assert(collectionView!.numberOfSections == 1)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true // invalidate on resize + on scroll
    }
    
    var _scrollDistPerItem: CGFloat {
        return 140
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collection = collectionView else { return CGSize.zero }
        return CGSize(width: collection.bounds.width, height: _scrollDistPerItem * CGFloat(collection.numberOfItems(inSection: 0)))
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var index = max(0, Int(_scrolledToIndex - 1))
        var attributes = [UICollectionViewLayoutAttributes]()
        while index < collectionView!.numberOfItems(inSection: 0) {
            let offset = _offset(forIndex: index)
            if offset > collectionView!.bounds.height {
                break
            }
            attributes.append(layoutAttributesForItem(at: IndexPath(item: index, section: 0))!)
            index += 1
        }
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attribs.frame = CGRect(x: 0, y: _offset(forIndex: indexPath.item) + collectionView!.contentOffset.y, width: collectionView!.bounds.width, height: collectionView!.bounds.height)
        attribs.zIndex = indexPath.item
        attribs.alpha = _fade(forIndex: indexPath.item)
        return attribs
    }
    
    var _scrolledToIndex: CGFloat {
        return collectionView!.contentOffset.y / _scrollDistPerItem
    }
    
    func _fade(forIndex index: Int) -> CGFloat {
        if CGFloat(index) < _scrolledToIndex {
            return max(0, 1 - (_scrolledToIndex - CGFloat(index)))
        } else {
            return 1
        }
    }
    
    func _offset(forIndex index: Int) -> CGFloat {
        return max(0, (CGFloat(index) - _scrolledToIndex) * _scrollDistPerItem)
    }
}
