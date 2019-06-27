//
//  SlidableTabPageController.swift
//  SlidableTabPageController
//
//  Created by Magnus Eriksson on 14/01/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit

//TODO: Think about the transition methods of the child view controllers.
//TODO: Make UI configurable. Make use of UIAppearance?


///Model of an index bar element of one page
public enum IndexBarElement {
    case title(String)
    case image(UIImage, UIImage)
}

///Model of one page, consisting of an index bar element and a content view controller
public struct SlidableTabPageControllerPage {
    public let indexBarElement: IndexBarElement
    public let contentViewController: UIViewController
    
    public init(indexBarElement: IndexBarElement, contentViewController: UIViewController) {
        self.indexBarElement = indexBarElement
        self.contentViewController = contentViewController
    }
    
    public init(contentViewController: UIViewController) {
        let indexBarElement: IndexBarElement
        if let image = contentViewController.tabBarItem.image,
            let selectedImage = contentViewController.tabBarItem.selectedImage {
            indexBarElement = IndexBarElement.image(image, selectedImage)
        } else {
            indexBarElement = IndexBarElement.title(contentViewController.title ?? "")
        }
        self.init(indexBarElement: indexBarElement, contentViewController: contentViewController)
    }
}


public struct SlidableTabPageControllerFactory {
    
    static public func make(pages: [SlidableTabPageControllerPage]) -> SlidableTabPageController {
        return SlidableTabPageController(pages: pages)
    }
}

public protocol SlidableTabPageControllerDelegate: class {
    func slidableTabPageController(_ slidableTabPageController: SlidableTabPageController,
                                   didNavigateFrom oldPage: Int, to newPage: Int)
}

public class SlidableTabPageController: UIViewController, UIScrollViewDelegate  {

    public enum IndexBarPosition {
        case top
        case bottom
    }


    //MARK: Views
    
    private lazy var verticalStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [])
        v.axis = .vertical
        v.alignment = .fill
        v.distribution = .fill
        v.spacing = 0
        return v
    }()


    public var indexBarHeightConstraint: NSLayoutConstraint?
    public var indexIndicatorViewCenterXConstraint: NSLayoutConstraint?
    private var indexIndicatorViewWidthConstraint: NSLayoutConstraint?

    public lazy var indexBarScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onIndexBarTapped(sender:))))
        sv.isDirectionalLockEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    public lazy var indexBarContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()

    public lazy var indexBarBottomSeparatorView: UIView = {
        let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()

    public lazy var indexIndicatorView: UIView = {
        let v = UIView()
        v.backgroundColor = .blue
        return v
    }()

    public lazy var contentScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.isDirectionalLockEnabled = true
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    public let contentContainerView = UIView()

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(indexBarScrollView)
        verticalStackView.addArrangedSubview(contentScrollView)

        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        verticalStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true


        // ### INDEX BAR VIEW ###

        indexBarScrollView.addSubview(indexBarContainerView)
        indexBarContainerView.addSubview(indexBarBottomSeparatorView)
        indexBarContainerView.addSubview(indexIndicatorView)

        indexBarScrollView.translatesAutoresizingMaskIntoConstraints = false
        indexBarContainerView.translatesAutoresizingMaskIntoConstraints = false
        indexBarBottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        indexIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        indexBarContainerView.leadingAnchor.constraint(equalTo: indexBarScrollView.leadingAnchor).isActive = true
        indexBarContainerView.trailingAnchor.constraint(equalTo: indexBarScrollView.trailingAnchor).isActive = true
        indexBarContainerView.topAnchor.constraint(equalTo: indexBarScrollView.topAnchor).isActive = true
        indexBarContainerView.bottomAnchor.constraint(equalTo: indexBarScrollView.bottomAnchor).isActive = true
        indexBarContainerView.heightAnchor.constraint(equalTo: indexBarScrollView.heightAnchor).isActive = true

        indexBarHeightConstraint = indexBarContainerView.heightAnchor.constraint(equalToConstant: 44)
        indexBarHeightConstraint!.priority = UILayoutPriority(rawValue: 999)
        indexBarHeightConstraint!.isActive = true

        indexBarBottomSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        indexBarBottomSeparatorView.widthAnchor.constraint(equalTo: indexBarContainerView.widthAnchor).isActive = true
        indexBarBottomSeparatorView.bottomAnchor.constraint(equalTo: indexBarContainerView.bottomAnchor).isActive = true
        indexBarBottomSeparatorView.centerXAnchor.constraint(equalTo: indexBarContainerView.centerXAnchor).isActive = true

        let indexIndicatorHeightConstraint = indexIndicatorView.heightAnchor.constraint(equalToConstant: 2)
        indexIndicatorHeightConstraint.priority = UILayoutPriority(rawValue: 999)
        indexIndicatorHeightConstraint.isActive = true
        indexIndicatorView.bottomAnchor.constraint(equalTo: indexBarContainerView.bottomAnchor).isActive = true
        indexIndicatorViewCenterXConstraint = indexIndicatorView.centerXAnchor.constraint(equalTo: indexBarContainerView.leadingAnchor)
        indexIndicatorViewCenterXConstraint!.isActive = true


        // ### CONTENT VIEW ###

        contentScrollView.addSubview(contentContainerView)

        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false

        contentContainerView.topAnchor.constraint(equalTo: contentScrollView.topAnchor).isActive = true
        contentContainerView.heightAnchor.constraint(equalTo: contentScrollView.heightAnchor).isActive = true
        contentContainerView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor).isActive = true
        contentContainerView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor).isActive = true
        contentContainerView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor).isActive = true
    }

    fileprivate init(pages: [SlidableTabPageControllerPage]) {
        super.init(nibName: nil, bundle: nil)
        defer {
            self.pages = pages
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Properties
    
    public weak var delegate: SlidableTabPageControllerDelegate?

    internal var indexBarElements: [IndexBarElementView] = []
    
    //Decides whether the indexBar should scroll to follow the index indicator view.
    private var indexBarShouldTrackIndicatorView = true
    
    private var pageIndexBeforeRotation: Int = 0
    
    //Keeps track of the current page index in order to track scroll direction (i.e. if scrolling backwards or forwards)
    public private(set) var currentPageIndex: Int = 0 {
        didSet {
            guard oldValue != currentPageIndex,
                let delegate = delegate else {
                    return
            }
            delegate.slidableTabPageController(self, didNavigateFrom: oldValue, to: currentPageIndex)
        }
    }
    
    public var pages: [SlidableTabPageControllerPage] = [] {
        willSet {
            removeContentView()
        }
        
        didSet {
            setupContentView()
            setupIndexBar()
            updateIndexIndicatorXPosition(percentage: 0)
        }
    }

    //MARK: Configurable
    
    public var maxNumberOfIndexBarElementsPerScreen = 3.5 {
        didSet {
            setupIndexBar()
            updateIndexIndicatorXPosition(percentage: 0)
        }
    }
    
    public var indexBarPosition: IndexBarPosition = .top {
        didSet {
            let index: Int
            switch indexBarPosition {
            case oldValue:          return                                     //Already at specified position
            case .top:              index = 0                                  //First
            case .bottom:           index = verticalStackView.subviews.count-1 //Last
            }
            
            DispatchQueue.main.async {
                self.verticalStackView.insertArrangedSubview(self.indexBarScrollView, at: index)
            }
        }
    }
    
    public var indexBarElementColor = UIColor.black {
        didSet { indexBarElements.forEach { $0.defaultColor = indexBarElementColor } }
    }
    
    public var indexBarElementHighlightedColor = UIColor.red {
        didSet { indexBarElements.forEach { $0.highlightedColor = indexBarElementHighlightedColor } }
    }
    
    //MARK: Rotation related events
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        pageIndexBeforeRotation = contentScrollView.ap_currentPage()
        
        coordinator.animate(alongsideTransition: { context in
            self.contentScrollView.ap_scrollToPageAtIndex(self.pageIndexBeforeRotation, animated: false)
            //Update the indicator view position manually in case no scroll was performed
            self.updateIndexIndicatorXPosition(percentage: self.contentScrollView.ap_horizontalPercentScrolled())
        }, completion: { _ in
            //Scroll the index indicator view to visible only after the its position has been completely updated
            self.scrollIndexIndicatorViewToVisible()
        })
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    //MARK: Setup
    
    private func setupIndexBar() {
        guard pages.count > 0 else {
            return
        }
        
        indexBarElements.forEach { $0.removeFromSuperview() }
        indexBarElements = createIndexBarElements()
        indexBarContainerView.ap_addViewsHorizontally(indexBarElements)
        
        //Make sure the indicator is not hidden behind the index bar elements
        indexBarContainerView.bringSubviewToFront(indexIndicatorView)
        
        NSLayoutConstraint.activate(
            indexBarElements.map { element -> NSLayoutConstraint in
                element.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: indexBarElementWidthMultiplier())
            })
        
        indexIndicatorViewWidthConstraint?.isActive = false
        let clampedWidth = clampedIndexIndicatorWidth(width: indexBarElements.first!.intrinsicContentSize.width)
        indexIndicatorViewWidthConstraint = indexIndicatorView.widthAnchor.constraint(equalToConstant: clampedWidth)
        indexIndicatorViewWidthConstraint?.isActive = true
    }
    
    
    /// Returns a clamped width within the min and max values
    private func clampedIndexIndicatorWidth(width: CGFloat) -> CGFloat {
        let minWidth: CGFloat = 15
        let maxWidth = indexBarElementWidth()
        return max(minWidth, min(maxWidth, width))
    }
    
    /**
     Creates an index bar element for each view controller.
     If the view controller has tab bar item images, then they will be used as the index bar element.
     Else the view controller's title will be used.
 
     */
    private func createIndexBarElements() -> [IndexBarElementView] {
        return pages.map { page in
            switch page.indexBarElement {
            case .title(let title):
                return IndexBarElementView(title: title,
                                             color: indexBarElementColor,
                                             highlightedColor: indexBarElementHighlightedColor)
            
            case let .image(defaultImage, highlightedImage):
                return IndexBarElementView(image: defaultImage,
                                             highlightedImage: highlightedImage,
                                             tintColor: indexBarElementColor)
            }
        }
    }
    
    private func indexBarElementWidth() -> CGFloat {
        return view.bounds.size.width * indexBarElementWidthMultiplier()
    }
    
    private func indexBarElementWidthMultiplier() -> CGFloat {
        let numberOfElements = Double(pages.count > 0 ? pages.count : 1)
        let multiplier = numberOfElements > maxNumberOfIndexBarElementsPerScreen ?
            CGFloat(1) / CGFloat(maxNumberOfIndexBarElementsPerScreen) :
            CGFloat(1) / CGFloat(numberOfElements)
        return multiplier
    }
    
    
    private func setupContentView() {
        let vcViews = pages.map { page -> UIView in
            addChild(page.contentViewController)
            page.contentViewController.didMove(toParent: self)
            return page.contentViewController.view
        }
        
        contentContainerView.ap_addViewsHorizontally(vcViews)
        
        NSLayoutConstraint.activate(
            vcViews.map { vcView -> NSLayoutConstraint in
                vcView.widthAnchor.constraint(equalTo: view.widthAnchor)
            })
        
        contentScrollView.ap_setHorizontalContentOffset(0)
    }
    
    private func removeContentView() {
        pages.forEach { page in
            page.contentViewController.willMove(toParent: nil)
            page.contentViewController.view.removeFromSuperview()
            page.contentViewController.removeFromParent()
        }
    }
    
    
    //MARK: UIScrollViewDelegate
    
    /**
     Navigates to the corresponding view controller of the index that was tapped
     */
    @objc func onIndexBarTapped(sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: sender.view)
        let indexOfElementAtTouchPoint = Int(touchPoint.x / indexBarElementWidth())
        
        //Don't scroll the index bar while moving indicator view
        indexBarShouldTrackIndicatorView = false
        
        contentScrollView.ap_scrollToPageAtIndex(indexOfElementAtTouchPoint, animated: true)
    }
    
    /**
     Updates the width of the 'indexIndicatorView' based on the transition progress and width delta of the source and destination index bar elements.
     Updates the position of the 'indexIndicatorView' based on the scroll-percentage of the 'content scroll view'.
     */
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == contentScrollView {
            
            //"percentScrolledInPage" represents the X-scroll percentage within the current page, starting at index 0.
            //E.g. if the scroll view is 50% between page 5 and 6, the  will be 4.5
            let percentScrolledInPage = contentScrollView.ap_horizontalPercentScrolledInCurrentPage()
            let percentScrolledInTotal = contentScrollView.ap_horizontalPercentScrolled()
            
            let isGoingBackwards = contentScrollView.ap_currentPage() < currentPageIndex
            var transitionProgress = percentScrolledInPage - CGFloat(contentScrollView.ap_currentPage())
            if isGoingBackwards {
                //If we're moving left, normalise the progress so that it always starts from 0 --> 1
                transitionProgress = (1 - transitionProgress)
            }
            
            //The index of the leftmost element involved in the transition
            let transitionLeftElementIndex = contentScrollView.ap_currentPage()
            let transitionRightElementIndex = transitionLeftElementIndex + 1
            
            let transitionSourceElementIndex = isGoingBackwards ? transitionRightElementIndex : transitionLeftElementIndex
            let transitionDestinationElementIndex = isGoingBackwards ? transitionLeftElementIndex : transitionRightElementIndex
            
            updateIndexIndicatorWidth(sourceElementIndex: transitionSourceElementIndex,
                                      destElementIndex: transitionDestinationElementIndex,
                                      transitionProgress: transitionProgress)
            
            updateIndexIndicatorXPosition(percentage: percentScrolledInTotal)
        }
    }
    
    /**
     Updates the width of the 'indexIndicatorView' by calculating the width delta 
     of the source and the destination elements involved in the transition and multiplying the delta with the transition progress.
     */
    private func updateIndexIndicatorWidth(sourceElementIndex: Int, destElementIndex: Int, transitionProgress: CGFloat) {
        //Ensure indices are within bounds
        var safeSourceIndex = sourceElementIndex >= 0 ? sourceElementIndex : 0
        safeSourceIndex = safeSourceIndex < indexBarElements.count ? safeSourceIndex : (indexBarElements.count - 1)
        
        var safeDestIndex = destElementIndex >= 0 ? destElementIndex : 0
        safeDestIndex = safeDestIndex < indexBarElements.count ? safeDestIndex : (indexBarElements.count - 1)
        
        //Fetch elements
        let sourceElement = indexBarElements[safeSourceIndex]
        let destElement = indexBarElements[safeDestIndex]
        
        //Calculate width
        let sourceElementWidth = clampedIndexIndicatorWidth(width: sourceElement.intrinsicContentSize.width)
        let destinationElementWidth = clampedIndexIndicatorWidth(width: destElement.intrinsicContentSize.width)
        let delta = destinationElementWidth - sourceElementWidth
        let newWidth = sourceElementWidth + (delta * transitionProgress)
        indexIndicatorViewWidthConstraint!.constant = clampedIndexIndicatorWidth(width: newWidth)
    }

    /**
     Updates the position of the 'indexIndicatorView' by 'xPercent'
     
     If the new position of the 'indexIndicatorView' is outside of the current page and tracking is set to true:
     - the content offset of the 'index bar' is updated accordingly.
     
     */
    private func updateIndexIndicatorXPosition(percentage percentageHorizontalOffset: CGFloat) {
        let indexIndicatorWidth = indexBarElementWidth()
        
        //Divide 'indexIndicatorWidth' by two since we're using the center of the line as x
        let newCenterX = (indexBarScrollView.contentSize.width - indexIndicatorWidth) * percentageHorizontalOffset + indexIndicatorWidth/2
        indexIndicatorViewCenterXConstraint?.constant = newCenterX
        
        highlightIndexBarElement(at: newCenterX)
        
        if indexBarShouldTrackIndicatorView {
            trackIndicatorView()
        }
    }
    
    private func trackIndicatorView() {
        let indicatorLeftX = indexIndicatorView.frame.origin.x
        let indicatorRightX = indicatorLeftX + indexIndicatorView.frame.width
        let frameLeftX = indexBarScrollView.contentOffset.x
        let frameRightX = frameLeftX + indexBarScrollView.frame.size.width
        
        let shouldScrollRight = indicatorRightX > frameRightX
        let shouldScrollLeft = indicatorLeftX < frameLeftX
        
        if shouldScrollRight {
            let newX = indexIndicatorView.frame.origin.x + indexIndicatorView.bounds.width - view.bounds.width
            indexBarScrollView.ap_setHorizontalContentOffset(newX)
        } else if shouldScrollLeft  {
            let newX = indexIndicatorView.frame.origin.x
            indexBarScrollView.ap_setHorizontalContentOffset(newX)
        }
    }
    
    /**
     Highlights the index bar element at position 'X'
     */
    private func highlightIndexBarElement(at x: CGFloat) {
        let indexOfElementAtXPosition = Int(x / indexBarElementWidth())

        for (index, page) in indexBarElements.enumerated() {
            page.isHighlighted = index == indexOfElementAtXPosition
        }
    }
    
    /**
     Called when the user taps on an element in the index bar, which triggers the content view to scroll.
     After scrolling of the 'contentScrollView' has occurred, scroll to make the 'index scroll view' visible.
     */
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == contentScrollView {
            scrollIndexIndicatorViewToVisible()
            
            //Restore tracking of indicator view
            indexBarShouldTrackIndicatorView = true
            
            //Save the current page index
            currentPageIndex = contentScrollView.ap_currentPage()
        }
    }
    
    /**
     Called when the user manually scrolls the content scroll view.
     After scrolling the 'content scroll view', scroll to make the 'index scroll view' visible.
     */
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == contentScrollView {
            scrollIndexIndicatorViewToVisible()
            
            //Restore tracking of indicator view
            indexBarShouldTrackIndicatorView = true
            
            //Save the current page index
            currentPageIndex = contentScrollView.ap_currentPage()
        }
    }
    
    /**
     Scrolls to make the 'index scroll view' (including a small margin) visible.
     */
    func scrollIndexIndicatorViewToVisible() {
        let frameWithMargin = indexIndicatorView.frame.insetBy(dx: -20, dy: 0)
        indexBarScrollView.scrollRectToVisible(frameWithMargin, animated: true)
    }
}
