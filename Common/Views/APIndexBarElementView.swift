//
//  APIndexBarElementView.swift
//  APSlidableTabPageController
//
//  Created by Magnus on 2017-03-17.
//  Copyright © 2017 Apegroup. All rights reserved.
//

import UIKit

final class APIndexBarElementView: UIView {
    
    //MARK: Properties
    
    var defaultColor: UIColor {
        didSet {
            let element = subviews.first!
            element.tintColor = defaultColor
            if let label = element as? UILabel {
                label.textColor = defaultColor
            }
        }
    }
    
    var highlightedColor: UIColor {
        didSet {
            let element = subviews.first!
            if let label = element as? UILabel {
                label.highlightedTextColor = highlightedColor
            }
        }
    }
    
    var isHighlighted: Bool {
        didSet {
            if let label = subviews.first as? UILabel {
                label.isHighlighted = isHighlighted
            } else if let imageView = subviews.first as? UIImageView {
                imageView.isHighlighted = isHighlighted
                imageView.tintColor = isHighlighted ?
                    highlightedColor : defaultColor
            }
        }
    }
    
    //MARK: Initialisers
    
    init(defaultColor: UIColor, highlightedColor: UIColor) {
        self.defaultColor = defaultColor
        self.highlightedColor = highlightedColor
        self.isHighlighted = false
        super.init(frame: CGRect.zero)
    }
    
    convenience init(title: String, color: UIColor, highlightedColor: UIColor) {
        self.init(defaultColor: color, highlightedColor: highlightedColor)
        let label = UILabel()
        label.text = title
        label.textColor = color
        label.highlightedTextColor = highlightedColor
        label.textAlignment = .center
        label.center(in: self)
    }
    
    convenience init(image: UIImage, highlightedImage: UIImage, tintColor: UIColor) {
        self.init(defaultColor: tintColor, highlightedColor: tintColor)
        let imageView = UIImageView(image: image, highlightedImage: highlightedImage)
        imageView.contentMode = .center
        imageView.tintColor = tintColor
        imageView.center(in: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Overridden

    override var intrinsicContentSize: CGSize {
        guard let subview = subviews.first else {
            fatalError("APIndexBarElementView is missing a subview")
        }
        return subview.intrinsicContentSize
    }
}
