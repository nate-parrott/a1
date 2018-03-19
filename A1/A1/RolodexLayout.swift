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
    
    let _decelRamp: CGFloat = 60
    let _decelFactor: CGFloat = 2
    var _additionalHeightToAccountForDecelRamp: CGFloat {
        return _decelRamp * (1 - 1.0 / _decelFactor)
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collection = collectionView else { return CGSize.zero }
        return CGSize(width: collection.bounds.width, height: _scrollDistPerItem * CGFloat(collection.numberOfItems(inSection: 0)) + _additionalHeightToAccountForDecelRamp)
    }
    
    let _loadCellsAbove = 3
    let _loadCellsBelow = 6
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var index = max(0, Int(_scrolledToIndex - 1) - _loadCellsAbove)
        var attributes = [UICollectionViewLayoutAttributes]()
        var extraCellsBelowRemaining = _loadCellsBelow
        while index < collectionView!.numberOfItems(inSection: 0) {
            let offset = _offset(forIndex: index)
            if offset > collectionView!.bounds.height {
                if extraCellsBelowRemaining <= 0 {
                    break
                }
                extraCellsBelowRemaining -= 1
            }
            attributes.append(layoutAttributesForItem(at: IndexPath(item: index, section: 0))!)
            index += 1
        }
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let offset = _offset(forIndex: indexPath.item)
        attribs.frame = CGRect(x: 0, y: offset + collectionView!.contentOffset.y, width: collectionView!.bounds.width, height: collectionView!.bounds.height)
        attribs.zIndex = indexPath.item
        attribs.alpha = 1 - _amountToFade(forIndex: indexPath.item)
        let zTranslate = 1 - offset / collectionView!.bounds.height
        attribs.transform3D = CATransform3DMakeTranslation(0, 0, zTranslate * -30)
        return attribs
    }
    
    var _scrolledToIndex: CGFloat {
        return collectionView!.contentOffset.y / _scrollDistPerItem
    }
    
    func _amountToFade(forIndex index: Int) -> CGFloat {
        let t = _scrolledToIndex
        let fadeStartAtT = CGFloat(index + 1)
        let fadeEndAtT = CGFloat(index + 2)
        if t < fadeStartAtT {
            return 0
        } else if t > fadeEndAtT {
            return 1
        } else {
            return (t - fadeStartAtT) / (fadeEndAtT - fadeStartAtT)
        }
    }
    
    func _offset(forIndex index: Int) -> CGFloat {
        var offset = max(0, (CGFloat(index) - _scrolledToIndex) * _scrollDistPerItem)
        if offset < _decelRamp {
            let t = (_decelRamp - offset) / _decelRamp
            let decelFn = decelerationFunction(factor: _decelFactor)
            offset = _decelRamp - decelFn(t) * _decelRamp
        }
        offset -= _additionalHeightToAccountForDecelRamp
        return offset
    }
}
