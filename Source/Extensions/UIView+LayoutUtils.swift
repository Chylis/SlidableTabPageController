//
//  UIView+LayoutUtils.swift
//  SlidableTabPageController
//
//  Created by Magnus Eriksson on 16/01/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit

extension UIView {
    
    func ap_addViewsHorizontally(_ views: [UIView]) {
        var prevView: UIView?
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.topAnchor.constraint(equalTo: topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            if prevView == nil {
                //First view - Pin to view's leading anchor
                view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            } else {
                //All other views - to to previous view's trailing anchor
                view.leadingAnchor.constraint(equalTo: prevView!.trailingAnchor).isActive = true
            }
            
            prevView = view;
        }
        
        //Last view - pin to container view's trailing anchor
        prevView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    func ap_center(in parentView: UIView, horizontalMargin: CGFloat = 0, verticalMargin: CGFloat = 0) {
        parentView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: horizontalMargin).isActive = true
        trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: horizontalMargin).isActive = true
        topAnchor.constraint(equalTo: parentView.topAnchor, constant: verticalMargin).isActive = true
        bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: verticalMargin).isActive = true
    }
    
    func ap_reportAmbiguity () {
        for subview in subviews {
            if subview.hasAmbiguousLayout {
                NSLog("Found ambigious layout: \(subview)")
            }
            
            if subview.subviews.count > 0 {
                subview.ap_reportAmbiguity()
            }
        }
    }
    
    func ap_listConstraints() {
        for subview in subviews {
            let arr1 = subview.constraintsAffectingLayout(for: .horizontal)
            let arr2 = subview.constraintsAffectingLayout(for: .vertical)
            NSLog("\n\n%@\nH: %@\nV:%@", subview, arr1, arr2)
            if subview.subviews.count > 0 {
                subview.ap_listConstraints()
            }
        }
    }
}
