//
//  UIScrollView+Utils.swift
//  WebWrapper
//
//  Created by Magnus Eriksson on 14/01/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    //MARK: UIScrollViewHelpers
    
    func ap_scrollToPageAtIndex(_ index: Int, animated: Bool = false) {
        let newX = CGFloat(index) * ap_pageSize()
        ap_setHorizontalContentOffset(newX, animated: animated)
    }
    
    /**
    "Safely" updates the scroll view's horizontal content offset within its bounds.
    Minimum value is 0 (i.e. left of first page).
    Maximum value is 'contentSize.width - pageSize' (i.e. left of last page)
    */
    func ap_setHorizontalContentOffset(_ x: CGFloat, animated: Bool = false) {
        let newX = max(ap_minimumHorizontalOffset(), min(ap_maximumHorizontalOffset(), x))
        setContentOffset(CGPoint(x: newX, y: 0), animated: animated)
    }
    
    /**
     Calculates the current X-scroll percentage within the content size
     */
    func ap_horizontalPercentScrolled() -> CGFloat {
        let maxHorizontalOffset = ap_maximumHorizontalOffset()
        if maxHorizontalOffset > 0 {
            return contentOffset.x / maxHorizontalOffset
        }
        return 0
    }
    
    /**
     Calculates the current X-scroll percentage within the current page.
     Starts at index 0. E.g. if the scroll view is 50% between page 5 and 6, this function will return 4.5
     */
    func ap_horizontalPercentScrolledInCurrentPage() -> CGFloat {
        let maxHorizontalOffset = ap_pageSize()
        if maxHorizontalOffset > 0 {
            return (contentOffset.x / maxHorizontalOffset)
        }
        
        return 0
    }
    
    /**
     Minimum value is 0 (i.e. left of first page).
     */
    func ap_minimumHorizontalOffset() -> CGFloat {
        return 0
    }
    
    /**
     Maximum value is 'contentSize.width - pageSize' (i.e. left of last page)
     */
    func ap_maximumHorizontalOffset() -> CGFloat {
        return contentSize.width - ap_pageSize()
    }
    
    /**
     Returns the current page number
     */
    func ap_currentPage() -> Int {
        guard contentOffset.x >= 0 else {
            return -1
        }
        
        let pageNumber = Int(contentOffset.x / ap_pageSize())
        return pageNumber
    }
    
    func ap_pageSize() -> CGFloat {
        return frame.size.width
    }
}
