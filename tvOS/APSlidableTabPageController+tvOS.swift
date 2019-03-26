//
//  APSlidableTabPageController+tvOS.swift
//  APSlidableTabPageController
//
//  Created by Magnus Eriksson on 2017-03-15.
//  Copyright © 2017. All rights reserved.
//

import UIKit

//MARK: TVOS UIFocusEnvironment

extension APSlidableTabPageController {
    
    //TODO: Consider alternative to extensions in a framework. 
    public override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let destinationView = context.nextFocusedView as? APIndexBarElementView,
            let destinationPageIndex = indexBarElements.firstIndex(of: destinationView) else {
                return
        }
        contentScrollView.ap_scrollToPageAtIndex(destinationPageIndex, animated: true)
    }
}


extension APIndexBarElementView {
    
    override var canBecomeFocused: Bool {
        return true
    }
}
