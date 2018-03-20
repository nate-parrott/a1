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
        return 200
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collection = collectionView else { return CGSize.zero }
        return CGSize(width: collection.bounds.width, height: _scrollDistPerItem * CGFloat(collection.numberOfItems(inSection: 0)))
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var index = _lowestIndexToRender
        // TODO: be more efficient
        var attributes = [UICollectionViewLayoutAttributes]()
        while index <= _maxIndexToRender && index < collectionView!.numberOfItems(inSection: 0) {
            attributes.append(layoutAttributesForItem(at: IndexPath(item: index, section: 0))!)
            index += 1
        }
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let y = _yPosition(forIndex: indexPath.item)
        attribs.frame = CGRect(x: 0, y: y + collectionView!.contentOffset.y, width: collectionView!.bounds.width, height: collectionView!.bounds.height)
        attribs.zIndex = indexPath.item
        // attribs.alpha = 1 - _amountToFade(forIndex: indexPath.item)
        // let zTranslate = 1 - offset / collectionView!.bounds.height
        // attribs.transform3D = CATransform3DMakeTranslation(0, 0, zTranslate * -30)
        return attribs
    }
    
    var _scrolledToIndex: CGFloat {
        return collectionView!.contentOffset.y / _scrollDistPerItem
    }
    
    var _maxIndexToRender: Int {
        return Int(ceil(_scrolledToIndex + _slideSpansNIndices))
    }
    
    var _lowestIndexToRender: Int {
        return max(0, Int(floor(_scrolledToIndex) - 1))
    }
    
    func _yPosition(forIndex index: Int) -> CGFloat { // y position, fixed within the viewport
        let viewportHeight = collectionView!.bounds.height
        
        // t = the distance from the bottom of the screen viewport,
        // before applying the slowdown function.
        
        // at scroll=0, index 0 should have t = 1
        // and index 3 should have t = 0
        
        // at scroll=3, index 3 should have t = 1
        // index 6 should have t = 0
        // index 7 should have t < 0
        
        // t is capped at 1
        
        let t = 1 - (CGFloat(index) - _scrolledToIndex) / (_slideSpansNIndices - 1)
        return viewportHeight * (1 - _slowdownCurve(min(1, t)))
    }
    
    let _slideSpansNIndices: CGFloat = 4
}

private func _slowdownCurve(_ t: CGFloat) -> CGFloat {
    return 1 - pow(t - 1, 2)
}
