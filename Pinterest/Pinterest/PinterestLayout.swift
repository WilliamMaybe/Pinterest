//
//  PinterestLayout.swift
//  Pinterest
//
//  Created by William Zhang on 16/6/21.
//  Copyright © 2016年 Razeware LLC. All rights reserved.
//

import UIKit

protocol PinterestLayoutDelegate {
  // 1
  func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath,
                      withWidth width:CGFloat) -> CGFloat
  // 2
  func collectionView(collectionView: UICollectionView,
                      heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
}

class PinterestLayoutAttributes: UICollectionViewLayoutAttributes {
  var photoHeight : CGFloat = 0.0
  
  override func copyWithZone(zone: NSZone) -> AnyObject {
    let copy = super.copyWithZone(zone) as! PinterestLayoutAttributes
    copy.photoHeight = photoHeight
    return copy
  }
  
  override func isEqual(object: AnyObject?) -> Bool {
    if let attributes = object as? PinterestLayoutAttributes {
      if attributes.photoHeight == photoHeight {
        return super.isEqual(object)
      }
    }
    
    return false
  }
}

class PinterestLayout: UICollectionViewLayout {
  
  // 1
  var delegate: PinterestLayoutDelegate!
  
  // 2
  var numberOfColumns = 2
  var cellPadding: CGFloat = 6.0
  
  // 3
  private var cache = [PinterestLayoutAttributes]()
  
  // 4
  private var contentHeight: CGFloat = 0.0
  private var contentWidth: CGFloat {
    let insets = collectionView!.contentInset
    return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
  }
  
  override class func layoutAttributesClass() -> AnyClass {
    return PinterestLayoutAttributes.self
  }
  
  override func prepareLayout() {
    guard cache.isEmpty else {
      return
    }
    
    let columnWidth = contentWidth / CGFloat(numberOfColumns)
    var xOffset = [CGFloat]()
    for column in 0 ..< numberOfColumns {
      xOffset.append(CGFloat(column) * columnWidth)
    }
    
    var column = 0
    var yOffset = [CGFloat](count: numberOfColumns, repeatedValue: 0)
    
    for item in 0 ..< collectionView!.numberOfItemsInSection(0) {
      let indexPath = NSIndexPath(forItem: item, inSection: 0)
      let width     = columnWidth - cellPadding * 2
      
      let phototHeight     = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath, withWidth: width)
      let annotationHeight = delegate.collectionView(collectionView!, heightForAnnotationAtIndexPath: indexPath, withWidth: width)
      let height           = phototHeight + annotationHeight + cellPadding * 2
      let frame            = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
      let insetFrame       = CGRectInset(frame, cellPadding, cellPadding)
      
      let attributes = PinterestLayoutAttributes(forCellWithIndexPath: indexPath)
      attributes.photoHeight = phototHeight
      attributes.frame = insetFrame
      cache.append(attributes)
      
      contentHeight = max(contentHeight, CGRectGetMaxY(frame))
      yOffset[column] += height
      
      column = (column + numberOfColumns + 1) % numberOfColumns
    }
  }
  
  override func collectionViewContentSize() -> CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  // called after prepareLayout()
  // the attributes of cells in the visible view's rect
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    for attributes in cache {
      if CGRectIntersectsRect(attributes.frame, rect) {
        layoutAttributes.append(attributes)
      }
    }
    
    return layoutAttributes
  }
}
