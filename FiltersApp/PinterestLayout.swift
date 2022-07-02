//
//  PinterestLayout.swift
//  FiltersApp
//
//  Created by Aliaksei Safronau EPAM on 26.01.22.
//

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(
        _ collectionView: UICollectionView,
        sizeOfImageAtIndexPath indexPath: IndexPath) -> CGSize
}

class PinterestLayout: UICollectionViewLayout {
    
    weak var delegate: PinterestLayoutDelegate?
    
    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 3
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    private var contentHeight: CGFloat = 0
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        super.prepare()
        // MARK: clean cash to recalculate LayoutAttributes for each collectionView.reloadData()
        self.cache.removeAll()
        
        guard
            let collectionView = collectionView
        else {
            return
        }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let photoSize = self.delegate?.collectionView(collectionView, sizeOfImageAtIndexPath: indexPath) ?? CGSize(width: columnWidth, height: columnWidth)
            let cellHeight = columnWidth * (photoSize.height / photoSize.width)
            let frame = CGRect(x: xOffset[column],
                               y: yOffset[column],
                               width: columnWidth,
                               height: cellHeight)
            let insetFrame = frame.insetBy(dx: self.cellPadding, dy: self.cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            self.cache.append(attributes)
            
            self.contentHeight = max(self.contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + cellHeight
            
            column = column < (self.numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        for attribute in cache {
            if attribute.frame.intersects(rect) {
                visibleLayoutAttributes.append(attribute)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
}
