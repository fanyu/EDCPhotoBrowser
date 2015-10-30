# EDCPhotoBrowser by Swift 

***PhotoBrowser like iOS Photos***

![Alt Text](https://github.com/fanyu/EDCPhotoBrowser/blob/master/Browser.gif)

##Features
* Show SpringEffect, No SpringEffect.

* Show ToolBar, No ToolBar. And Counter Label, Back/Forward Arrow Button. 

* Double tap to ZoomIn or ZoomOut.

* Single tap to dismiss.

* Pan up or down to dismiss. 

##Usage 
```swift
func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CollectionViewCell
        
        cell.imageView.image = UIImage(named: photos[indexPath.item])
  
        alllOrginCells.append(cell)
        
        return cell
    }

func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let browser = EDCPhotoBrowser(startIndex: indexPath.row, allOrginCells: alllOrginCells, showToolBar: displayToolBar, showArrowButton: true, showCuounterLabel: true, springEffect: springEffect)
       
        presentViewController(browser, animated: true, completion: nil)
}
```


##Others
All Photos are from my Instagram : edceezz.
