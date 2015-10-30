# EDCPhotoBrowser
***PhotoBrowser like iOS Photos***

![Alt Text](https://github.com/fanyu/EDCPhotoBrowser/blob/master/Browser.gif)

##Style 
Show SpringEffect, No SpringEffect.

Show ToolBar, No ToolBar.

Double tap to zoomin and zoomout.

Single tap to dismiss.

Pan up or down to dismiss. 

##How to use 
```swift
func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let browser = EDCPhotoBrowser(startIndex: indexPath.row, allOrginCells: alllOrginCells, showToolBar: displayToolBar, showArrowButton: true, showCuounterLabel: true, springEffect: springEffect)
       
        presentViewController(browser, animated: true, completion: nil)
}
```
