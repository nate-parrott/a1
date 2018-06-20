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
    
    let _itemsPerPage = 3
    var _nPages: Int {
        return max(1, Int(ceil(CGFloat(collectionView!.numberOfItems(inSection: 0)) / CGFloat(_itemsPerPage))))
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collection = collectionView else { return CGSize.zero }
        return CGSize(width: collection.bounds.width, height: CGFloat(_nPages) * collection.bounds.height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let (fromPage, toPage, _) = _pagePosition()
        var attribs = [UICollectionViewLayoutAttributes]()
        let maxIndex = min(collectionView!.numberOfItems(inSection: 0), (toPage + 1) * _itemsPerPage)
        var i = max(0, fromPage * _itemsPerPage)
        while i < maxIndex {
            attribs.append(layoutAttributesForItem(at: IndexPath(item: i, section: 0))!)
            i += 1
        }
        return attribs
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let y = _yPosition(forIndex: indexPath.item)
        attribs.frame = CGRect(x: 0, y: y + collectionView!.contentOffset.y, width: collectionView!.bounds.width, height: collectionView!.bounds.height)
        attribs.zIndex = indexPath.item
        return attribs
    }
    
    func _yPosition(forIndex index: Int) -> CGFloat {
        let (fromPage, toPage, progress) = _pagePosition()
        let fromPos = _yPosition(forIndex: index, onPage: fromPage)
        let toPos = _yPosition(forIndex: index, onPage: toPage)
        return _lerp(from: fromPos, to: toPos, t: progress)
    }
    
    func _yPosition(forIndex index: Int, onPage page: Int) -> CGFloat {
        let pageForIndex = index / _itemsPerPage
        if pageForIndex < page {
            return 0
        }
        let positionIfOnCurrentPage = CGFloat(index % _itemsPerPage) / CGFloat(_itemsPerPage) * collectionView!.bounds.height
        if pageForIndex > page {
            return positionIfOnCurrentPage + collectionView!.bounds.height
        } else {
            return positionIfOnCurrentPage
        }
    }
    
    func _pagePosition() -> (fromPage: Int, toPage: Int, progress: CGFloat) {
        let fractionalPage = collectionView!.contentOffset.y / collectionView!.bounds.height
        let fromPage = Int(floor(fractionalPage))
        return (fromPage: fromPage, toPage: fromPage + 1, progress: fractionalPage.truncatingRemainder(dividingBy: 1))
    }
}

private func _slowdownCurve(_ t: CGFloat) -> CGFloat {
    return 1 - pow(t - 1, 2)
}

private func _lerp(from: CGFloat, to: CGFloat, t: CGFloat) -> CGFloat {
    return from * (1 - t) + to * t
}
