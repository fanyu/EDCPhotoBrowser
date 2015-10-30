//
//  EDCZoomingScrollView.swift
//  EDCPhotoBrowser
//
//  Created by FanYu on 26/10/2015.
//  Copyright © 2015 FanYu. All rights reserved.
//

import UIKit

protocol EDCZoomingScrollViewDelegate {
    func didZoomInOut(zoom: String)
}

class EDCZoomingScrollView: UIScrollView {
    
    var edcDelegate: EDCZoomingScrollViewDelegate?
    
    var imageView = UIImageView()
    var photo: UIImage! {
        didSet {
            displayImage()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let boundsSize = self.bounds.size
        var frameToCenter = imageView.frame
        
        // horizon 
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        // vertical 
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        // if different, then resize imageView's frame
        if !CGRectEqualToRect(imageView.frame, frameToCenter) {
            imageView.frame = frameToCenter
        }
    }
}


// MARK: - setup
//
extension EDCZoomingScrollView {
    func setup() {
        
        // image view
        imageView = UIImageView(frame: frame)
        imageView.backgroundColor = UIColor.blackColor()//clearColor()
        addSubview(imageView)
        
        // self
        self.backgroundColor = UIColor.blackColor()//clearColor()
        self.delegate = self
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // Tap Gesture
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1 // fingures
        self.addGestureRecognizer(doubleTapRecognizer)
    }
}


// MARK: - Show Image
//
extension EDCZoomingScrollView {
    
    func displayImage() {
        if let image = photo { // photo from tilePage
            imageView.image = image
            imageView.frame.size = image.size
            setMaxMinZoomScalesForCurrentBounds()
        }
        setNeedsLayout()
    }
}


// MARK: - Zoom
//
extension EDCZoomingScrollView {
    func setMaxMinZoomScalesForCurrentBounds() {
        // reset scale
        self.minimumZoomScale = 1
        self.maximumZoomScale = 1
        self.zoomScale = 1
        
        let boundsSize = self.bounds.size // screen bounds
        let imageSize = imageView.frame.size
        
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        
        var maxScale: CGFloat = 4
        let minScale: CGFloat = min(xScale, yScale)
        
        self.maximumZoomScale = maxScale
        self.minimumZoomScale = minScale
        self.zoomScale = minScale
        
        maxScale = maxScale / UIScreen.mainScreen().scale
        if maxScale < minScale {
            maxScale = minScale * 2
        }
        
        // reset position
        imageView.frame = CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height)
        setNeedsLayout() // update next cycle
    }
        
    func zoomRectForScrollView(withScale: CGFloat, touchPoint: CGPoint) ->CGRect {
        let newX = touchPoint.x - self.frame.size.width / 2
        let newY = touchPoint.y - self.frame.size.height / 2
        return CGRect(x: newX, y: newY, width: self.frame.size.width, height: self.frame.size.height)
    }
}


// MARK: - Tap Gesture
//
extension EDCZoomingScrollView {
    
    // Double
    func handleDoubleTap(sender: UIGestureRecognizer) {
        let pointInView = sender.locationInView(self.imageView)
        
        if zoomScale > minimumZoomScale {
            setZoomScale(minimumZoomScale, animated: true)
            edcDelegate?.didZoomInOut("ZoomOut")
        } else {
            var newZoom: CGFloat = zoomScale * 2.0
            if newZoom >= maximumZoomScale {
                newZoom = maximumZoomScale
            }
            self.zoomToRect(zoomRectForScrollView(newZoom, touchPoint: pointInView), animated: true)
            edcDelegate?.didZoomInOut("ZoomIn")
        }
    }
}


// MARK: - Scroll Delegate
//
extension EDCZoomingScrollView: UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        setNeedsLayout()
        layoutIfNeeded()
    }
}



