//
//  ViewController.swift
//  EDCPhotoBrowser
//
//  Created by FanYu on 26/10/2015.
//  Copyright © 2015 FanYu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var photos = ["1", "2", "3", "4","5", "6", "7","8", "9", "10", "11","12", "13"]
    var alllOrginCells = [CollectionViewCell]()
    
    var springEffect = true
    var displayToolBar = true
    
    // spring button
    @IBOutlet weak var sprintButton: UIButton!
    @IBAction func springButtonTapped(sender: UIButton) {
        
        if springEffect {
            sender.setTitle("NoSpring", forState: .Normal)
        } else {
            sender.setTitle("Spring", forState: .Normal)
        }
        springEffect = !springEffect
    }
    
    
    // tool button 
    @IBOutlet weak var showToolBar: UIButton!
    @IBAction func toolBarButtonTapped(sender: UIButton) {
        
    if displayToolBar {
            sender.setTitle("NoBar", forState: .Normal)
        } else {
            sender.setTitle("ToolBar", forState: .Normal)
        }
        displayToolBar = !displayToolBar
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        setupButtonAnimaiton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Button Animation 
// 
extension ViewController {
    func setupButtonAnimaiton() {
        // spring button
        sprintButton.layer.cornerRadius = sprintButton.frame.size.width / 2
        sprintButton.layer.shadowColor = UIColor.whiteColor().CGColor
        sprintButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        sprintButton.layer.shadowOpacity = 0.9
        sprintButton.layer.shadowRadius = 25
        
        let animation = CABasicAnimation.init(keyPath: "shadowOpacity")
        animation.fromValue = 0.9
        animation.toValue = 0.2
        animation.duration = 1.5
        animation.autoreverses = true
        animation.repeatCount = MAXFLOAT
        sprintButton.layer.addAnimation(animation, forKey: "sprintButton")
        
        
        // toolbar button
        showToolBar.layer.cornerRadius = showToolBar.frame.size.width / 2
        showToolBar.layer.shadowColor = UIColor.whiteColor().CGColor
        showToolBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        showToolBar.layer.shadowOpacity = 0.9
        showToolBar.layer.shadowRadius = 25
        
        let animation2 = CABasicAnimation.init(keyPath: "shadowOpacity")
        animation2.fromValue = 0.9
        animation2.toValue = 0.2
        animation2.duration = 1.5
        animation2.autoreverses = true
        animation2.repeatCount = MAXFLOAT
        showToolBar.layer.addAnimation(animation2, forKey: "displayToolBar")
    }
}


// MARK: - CollectionView Delegate DataSource
//
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // data source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CollectionViewCell
        
        cell.imageView.image = UIImage(named: photos[indexPath.item])
  
        alllOrginCells.append(cell)
        
        
        return cell
    }
    
    
    // Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let browser = EDCPhotoBrowser(startIndex: indexPath.row, allOrginCells: alllOrginCells, showToolBar: displayToolBar, showArrowButton: true, showCuounterLabel: true, springEffect: springEffect)
        presentViewController(browser, animated: true, completion: nil)
    }
}



// MARK: - CollectionView Delegate FlowLayout
//
extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemWidth = (view.bounds.size.width - 2) / 3
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
}
