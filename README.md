# EDCPhotoBrowser
PhotoBrowser like iOS Photos

Show SpringEffect, No SpringEffect.
Show ToolBar, No ToolBar.
Double tap to zoomin and zoomout.
Single tap to dismiss.
Pan up or down to dismiss. 

![Alt Text](https://github.com/fanyu/EDCPhotoBrowser/blob/master/Browser.gif)

##How to use 
func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let browser = EDCPhotoBrowser(startIndex: indexPath.row, allOrginCells: alllOrginCells, showToolBar: displayToolBar, showArrowButton: true, showCuounterLabel: true, springEffect: springEffect)
        presentViewController(browser, animated: true, completion: nil)
    }
