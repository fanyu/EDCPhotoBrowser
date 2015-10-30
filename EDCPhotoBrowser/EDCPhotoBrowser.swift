//
//  EDCPhotoBrowser.swift
//  EDCPhotoBrowser
//
//  Created by FanYu on 26/10/2015.
//  Copyright © 2015 FanYu. All rights reserved.
//
    
    
import UIKit

class EDCPhotoBrowser: UIViewController {

    // device property
    var screenWidth: CGFloat { return UIScreen.mainScreen().bounds.width }
    var screenHeight: CGFloat { return UIScreen.mainScreen().bounds.height }
    
    // scroll view
    var horizontalScrollView: UIScrollView!
    var applicationWindow: UIWindow!
    
    // paging
    let pageIndexTagOffset = 520
    var currentPageIndex: Int = 0
    var visiblePages: Set<EDCZoomingScrollView> = Set()
    
    // status check
    var isViewActive: Bool = false
    var isPerformingLayout: Bool = false
    
    // var photos
    var photos = [UIImage]()
    var numberOfPhotos: Int {
        return photos.count
    }
    
    // sender view's property
    var originCells: [UIView]?
    var startIndex: Int?
    
    // animation property
    let animationDuration: Double = 0.35
    var animationImageView: UIImageView = UIImageView()
    var useSpringEffect = false
    
    // tool bar
    var toolBar: UIToolbar!
    var toolCounterLabel: UILabel!
    var toolCounterButton: UIBarButtonItem!
    var toolPreviousButton: UIBarButtonItem!
    var toolNextButton: UIBarButtonItem!
    var displayToolbar = false
    var displayArrowButton = false
    var displayCounterLabel = false
    
    // MARK: - LifeCycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    convenience init(startIndex:Int, allOrginCells: [CollectionViewCell], showToolBar: Bool, showArrowButton: Bool, showCuounterLabel: Bool, springEffect: Bool) {
        self.init(nibName: nil, bundle: nil)
        
        self.useSpringEffect = springEffect
        self.displayToolbar = showToolBar
        self.displayArrowButton = showArrowButton
        self.displayCounterLabel = showCuounterLabel
        
        self.originCells = allOrginCells
        self.startIndex = startIndex
        self.currentPageIndex = startIndex

        for cell in allOrginCells{
            self.photos.append(cell.imageView.image!)
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        isPerformingLayout = true
        
        horizontalScrollView.frame = frameForhorizontalScrollView()
        horizontalScrollView.contentSize = contentSizeForhorizontalScrollView()
        horizontalScrollView.contentOffset = contentOffsetForPageAtIndex(currentPageIndex)
        
        isPerformingLayout = false
    }
    
    // load the first page
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        performLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        isViewActive = true
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        
        horizontalScrollView = nil
        visiblePages = Set()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}


// MARK: - Setup View
//
extension EDCPhotoBrowser {
    
    func setup() {
        applicationWindow = (UIApplication.sharedApplication().delegate?.window)!
        
        modalPresentationStyle = UIModalPresentationStyle.Custom
        modalPresentationCapturesStatusBarAppearance = true
        modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    }
    
    func setupView() {
        
        // bottom view
        view.backgroundColor = UIColor.blackColor()
        view.clipsToBounds = true
        
        // scroll view
        let horizontalScrollViewFrame = frameForhorizontalScrollView()
        horizontalScrollView = UIScrollView(frame: horizontalScrollViewFrame)
        horizontalScrollView.pagingEnabled = true
        horizontalScrollView.delegate = self
        horizontalScrollView.showsHorizontalScrollIndicator = true
        horizontalScrollView.showsVerticalScrollIndicator = true
        horizontalScrollView.backgroundColor = UIColor.blackColor()
        horizontalScrollView.contentSize = contentSizeForhorizontalScrollView()
        view.addSubview(horizontalScrollView)
        
        // toolbar
        toolBar = UIToolbar(frame: frameForToolbar())
        toolBar.backgroundColor = UIColor.clearColor()
        toolBar.clipsToBounds = true
        toolBar.translucent = true
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .Bottom, barMetrics: .Default)
        view.addSubview(toolBar)
        
        if displayToolbar {
            toolBar.hidden = false
        } else {
            toolBar.hidden = true
        }
        
        // prvious arrow
        let previousButton = UIButton(type: .Custom)
        previousButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        previousButton.imageEdgeInsets = UIEdgeInsets(top: 13.25, left: 17.25, bottom: 13.25, right: 17.25)
        previousButton.setImage(UIImage(named: "btn_previous"), forState: .Normal)
        previousButton.addTarget(self, action: "handleGoPrevious", forControlEvents: .TouchUpInside)
        previousButton.contentMode = .Center
        self.toolPreviousButton = UIBarButtonItem(customView: previousButton)
        
        // next arrow
        let nextButton = UIButton(type: .Custom)
        nextButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        nextButton.imageEdgeInsets = UIEdgeInsets(top: 13.25, left: 17.25, bottom: 13.25, right: 17.25)
        nextButton.setImage(UIImage(named: "btn_next"), forState: .Normal)
        nextButton.addTarget(self, action: "handleGoNext", forControlEvents: .TouchUpInside)
        nextButton.contentMode = .Center
        self.toolNextButton = UIBarButtonItem(customView: nextButton)

        // counter label
        toolCounterLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 95, height: 40))
        toolCounterLabel.textAlignment = .Center
        toolCounterLabel.backgroundColor = UIColor.clearColor()
        toolCounterLabel.font = UIFont.systemFontOfSize(16)
        toolCounterLabel.textColor = UIColor.whiteColor()
        toolCounterLabel.shadowColor = UIColor.darkTextColor()
        toolCounterLabel.shadowOffset = CGSize(width: 0, height: 1)
        self.toolCounterButton = UIBarButtonItem(customView: toolCounterLabel)
        
        
        // tap gesture
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: nil)
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1 // fingures
        self.view.addGestureRecognizer(doubleTapRecognizer)
        
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(singleTapRecognizer)
        
        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        
        // pan gesture
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(panRecognizer)
        
        // transition, must be last call of view did load
        performPresentAnimation()
    }
    
    func performLayout() {
        
        isPerformingLayout = true
        
        // tool bar 
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        
        if numberOfPhotos > 1 && displayArrowButton {
            items.append(toolPreviousButton)
        }
        
        if displayCounterLabel {
            items.append(flexSpace)
            items.append(toolCounterButton)
            items.append(flexSpace)
        } else {
            items.append(flexSpace)
        }
        
        if numberOfPhotos > 1 && displayArrowButton {
            items.append(toolNextButton)
        }
        
        items.append(flexSpace)
        
        toolBar.setItems(items, animated: false)
        updateToolbar()
        
        
        // reset local cache
        visiblePages.removeAll()
        
        // set content offset 
        horizontalScrollView.contentOffset = contentOffsetForPageAtIndex(currentPageIndex)
        
        // add page
        addPages()
        
        isPerformingLayout = false
        
        view.setNeedsLayout()
    }
}

    
// MARK: - ToolBar
//
extension EDCPhotoBrowser {
    
    func updateToolbar() {
        if numberOfPhotos > 1 {
            toolCounterLabel.text = "\(currentPageIndex + 1) / \(numberOfPhotos)"
        } else {
            toolCounterLabel.text = nil
        }
        
        toolPreviousButton.enabled = (currentPageIndex > 0)
        toolNextButton.enabled = (currentPageIndex < numberOfPhotos - 1)
    }
}
    
    
// MARK: - Action 
//
extension EDCPhotoBrowser {
    
    func handleSingleTap(sender: UITapGestureRecognizer) {
        performCloseAnimationWithScrollView()
    }
    
    func panFrameAnimation(scrollView: EDCZoomingScrollView, duration: NSTimeInterval, finalY: CGFloat, dimissVC: Bool) {
        UIView.animateWithDuration(duration, animations: { () -> Void in
            if dimissVC {
                scrollView.frame.origin.y = finalY
                self.view.alpha = 0.0
            } else {
                scrollView.center.y = self.screenHeight / 2
                self.view.alpha = 1
            }
            }) { (dismissVC) -> Void in
                if dimissVC {
                    self.dismissViewControllerAnimated(false, completion: nil)
                }
        }
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        
        let zoomingScrollView = pageDisplayedAtIndex(currentPageIndex)
        let translationPoint = sender.translationInView(self.view)
        
        if sender.state == .Began {
            zoomingScrollView.backgroundColor = UIColor.clearColor()
            zoomingScrollView.imageView.backgroundColor = UIColor.blackColor()
            self.horizontalScrollView.backgroundColor = UIColor.clearColor()
            self.view.backgroundColor = UIColor.blackColor()
            self.view.alpha = 1.0
        } else if sender.state == .Changed {  
            let deltaY = 1 - fabs(translationPoint.y) / screenHeight
            
            zoomingScrollView.frame.origin.y = translationPoint.y
            self.view.alpha = deltaY
            
        } else if sender.state == .Ended || sender.state == .Failed || sender.state == .Cancelled {
            
            let velocityY = sender.velocityInView(self.view).y
            let finalY = translationPoint.y > 0 ? screenHeight : -screenHeight
            
            if velocityY < -500 { // Up Disappear
                panFrameAnimation(zoomingScrollView, duration: 0.25, finalY: finalY, dimissVC: true)
            } else if velocityY > 500 { // Down Disappear
                panFrameAnimation(zoomingScrollView, duration: 0.25, finalY: finalY, dimissVC: true)
            } else if zoomingScrollView.center.y < 10 || zoomingScrollView.center.y > screenHeight - 10 {
                panFrameAnimation(zoomingScrollView, duration: 0.25, finalY: finalY, dimissVC: true)
            } else { // 回到原位置
                panFrameAnimation(zoomingScrollView, duration: 0.25, finalY: finalY, dimissVC: false)
            }
        }
    }
    
    func handleGoPrevious() {
        jumpToPageAtIndex(currentPageIndex - 1)
    }
    
    func handleGoNext() {
        jumpToPageAtIndex(currentPageIndex + 1)
    }
}

// MARK: - Paging
//
extension EDCPhotoBrowser {
    
    func jumpToPageAtIndex(index:Int){  // set content offset
        if index < numberOfPhotos {
            let pageFrame = frameForPageAtIndex(index)
            horizontalScrollView.setContentOffset(CGPointMake(pageFrame.origin.x - 10, 0), animated: true)
            updateToolbar()
        }
    }
    
    func photoAtIndex(index: Int) ->UIImage {
        return photos[index]
    }

    
    func addPages() {
        
        let visibleBounds = horizontalScrollView.bounds // not content size
        
        var firstIndex = Int(floor((CGRectGetMinX(visibleBounds) + 10 * 2) / CGRectGetWidth(visibleBounds)))
        var lastIndex  = Int(floor((CGRectGetMaxX(visibleBounds) - 10 * 2 - 1) / CGRectGetWidth(visibleBounds)))
        
        if firstIndex < 0 {
            firstIndex = 0
        }
        
        if firstIndex > numberOfPhotos - 1 {
            firstIndex = numberOfPhotos - 1
        }
        
        if lastIndex < 0 {
            lastIndex = 0
        }
        
        if lastIndex > numberOfPhotos - 1 {
            lastIndex = numberOfPhotos - 1
        }
        
        for index in firstIndex ... lastIndex {
            
            if !isDisplayingPageAtIndex(index){ // don't add current displayed page
                // init the new page
                let page = EDCZoomingScrollView(frame: view.frame)
                page.frame = frameForPageAtIndex(index)
                page.tag = index + pageIndexTagOffset
                page.photo = photoAtIndex(index)
                page.edcDelegate = self
                visiblePages.insert(page)
                horizontalScrollView.addSubview(page)
            }
        }
    }
    
    func isDisplayingPageAtIndex(index: Int) -> Bool{
        for page in visiblePages{
            if (page.tag - pageIndexTagOffset) == index {
                return true
            }
        }
        return false
    }
    
    func contentOffsetForPageAtIndex(index:Int) -> CGPoint{
        let pageWidth = horizontalScrollView.bounds.size.width
        let newOffset = CGFloat(index) * pageWidth
        return CGPointMake(newOffset, 0)
    }

    func pageDisplayedAtIndex(index: Int) ->EDCZoomingScrollView {
        var thePage = EDCZoomingScrollView()
        for page in visiblePages {
            if page.tag - pageIndexTagOffset == index {
                thePage = page
                break
            }
        }
        return thePage
    }
}


//MARK: - Frame and size
//
extension EDCPhotoBrowser {
    
    func frameForhorizontalScrollView() ->CGRect {
        var frame = self.view.bounds
        frame.origin.x -= 10
        frame.size.width += (2 * 10)
        return frame
    }
    
    func contentSizeForhorizontalScrollView() ->CGSize {
        let bounds = horizontalScrollView.bounds
        let width = bounds.size.width * CGFloat(numberOfPhotos)
        let height = bounds.size.height
        return CGSize(width: width, height: height)
    }
    
    func frameForPageAtIndex(index: Int) -> CGRect {
        let bounds = horizontalScrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= (2 * 10)
        pageFrame.origin.x = (bounds.size.width * CGFloat(index)) + 10
        return pageFrame
    }
    
    func frameForToolbar() ->CGRect {
        return CGRect(x: 0, y: view.bounds.size.height - 44, width: view.bounds.size.width, height: 44)
    }
}
    
    
// MARK: - Animation
//
extension EDCPhotoBrowser {
    
    func getScaledImageFrame(sender: UIImage) ->CGRect{
        
        var finalImageViewFrame = CGRect.zero
        var scaleFactor: CGFloat = 0
        var scaledImageWidth: CGFloat = 0
        var scaledImageHeight: CGFloat = 0
        
        if sender.size.height / sender.size.width > screenHeight / screenWidth { // long photo
            scaleFactor = sender.size.height / screenHeight
            scaledImageWidth = sender.size.width / scaleFactor
            finalImageViewFrame = CGRect(x: screenWidth / 2 - scaledImageWidth / 2 , y: 0, width: scaledImageWidth, height: screenHeight)
        } else { // wide photo
            scaleFactor = sender.size.width / screenWidth
            scaledImageHeight = sender.size.height / scaleFactor
            finalImageViewFrame = CGRect(x: 0, y: (screenHeight/2) - (scaledImageHeight/2), width: screenWidth, height: scaledImageHeight)
        }
        return finalImageViewFrame
    }
    
    func performPresentAnimation() {
        // get the view be transparence
        horizontalScrollView.alpha = 0.0
            
        let fadeView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        fadeView.backgroundColor = UIColor.clearColor()
        applicationWindow.addSubview(fadeView)
            
        // converts to window base coordinates
        let startCell = originCells![startIndex!]
        let frameFromStartView = startCell.superview?.convertRect(startCell.frame, toView: nil)
        
        animationImageView = UIImageView(image: photoAtIndex(startIndex!))
        animationImageView.frame = frameFromStartView!
        animationImageView.clipsToBounds = true
        animationImageView.contentMode = .ScaleAspectFill
        applicationWindow.addSubview(animationImageView)

        startCell.hidden = true
        
        let scaledImageViewFrame = getScaledImageFrame(photoAtIndex(startIndex!))
        
        // animation
        if useSpringEffect {
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 20, options: .CurveEaseOut, animations: { () -> Void in
                self.animationImageView.layer.frame = scaledImageViewFrame
                fadeView.alpha = 1
                }) { (Bool) -> Void in
                    self.horizontalScrollView.alpha = 1.0
                    self.animationImageView.removeFromSuperview()
                    fadeView.removeFromSuperview()
                    startCell.hidden = false
            }
            
        } else {
            
            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                self.animationImageView.layer.frame = scaledImageViewFrame
                
                }, completion: { (Bool) -> Void in
                    self.horizontalScrollView.alpha = 1.0
                    self.animationImageView.removeFromSuperview()
                    fadeView.removeFromSuperview()
                    startCell.hidden = false
            })
        }
    }
    
    func performCloseAnimationWithScrollView() {
        
        let fadeView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        fadeView.backgroundColor = UIColor.blackColor()
        fadeView.alpha = 1.0
        applicationWindow.addSubview(fadeView)
        
        let lastCell = originCells![currentPageIndex]
        let frameFromLastView = lastCell.superview?.convertRect(lastCell.frame, toView: self.view)
        
        let scaledLastViewFrame = getScaledImageFrame(photoAtIndex(currentPageIndex))
        
        animationImageView = UIImageView(image: photoAtIndex(currentPageIndex))
        animationImageView.frame = scaledLastViewFrame
        animationImageView.alpha = 1.0
        animationImageView.backgroundColor = UIColor.greenColor()
        animationImageView.clipsToBounds = true
        animationImageView.contentMode = .ScaleAspectFill
        applicationWindow.addSubview(animationImageView)
        
        lastCell.hidden = true
        
        view.hidden = true
        
        if useSpringEffect {
            
            UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 20, options: .CurveEaseOut, animations: { () -> Void in
                fadeView.alpha = 0.0
                self.animationImageView.layer.frame = frameFromLastView!
                }, completion: { (Bool) -> Void in
                    self.animationImageView.removeFromSuperview()
                    fadeView.removeFromSuperview()
                    self.dismissViewControllerAnimated(true, completion: nil)
                    lastCell.hidden = false
            })
            
        } else {
            
            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                fadeView.alpha = 0.0
                self.animationImageView.layer.frame = frameFromLastView!
                
                }) { (Bool) -> Void in
                    self.animationImageView.removeFromSuperview()
                    fadeView.removeFromSuperview()
                    self.dismissViewControllerAnimated(true, completion: nil)
                    lastCell.hidden = false 
            }
        }
    }
}

// MARK: - Scroll View Delegate
//
extension EDCPhotoBrowser: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !isViewActive {
            return
        }
        if isPerformingLayout {
            return
        }
        
        // add page
        addPages()
        
        // Calculate current page ???
        let visibleBounds = horizontalScrollView.bounds
        var index = Int(floor(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)))
        
        if index < 0 {
            index = 0
        }
        if index > numberOfPhotos - 1 {
            index = numberOfPhotos
        }
        
        let previousPageIndex = currentPageIndex
        currentPageIndex = index
        
        if currentPageIndex != previousPageIndex {
            updateToolbar()
        }
    }
}

    
extension EDCPhotoBrowser: EDCZoomingScrollViewDelegate {
    func didZoomInOut(zoom: String) {
        if zoom == "ZoomIn" && displayToolbar{
            toolBar.hidden = true
        } else if zoom == "ZoomOut" && displayToolbar {
            toolBar.hidden = false
        }
    }
}

