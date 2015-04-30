//
//  FlickrPhotoViewController.swift
//  Assignment-3
//
//  Created by admin on 29/04/15.
//  Copyright (c) 2015 mihaeu. All rights reserved.
//

import UIKit
import ZLBalancedFlowLayout

struct Storyboard
{
    private static let locationSegue = "Show Location"
    private static let photoCellIdentifier = "MyCell"
}

class FlickrPhotoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate
{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var model: [FlickrPhoto] = [FlickrPhoto]()

    @IBAction func clear(sender: AnyObject)
    {
        let deleteIndexPath = collectionView.indexPathsForVisibleItems()[0] as! NSIndexPath
        collectionView.deleteItemsAtIndexPaths([deleteIndexPath])
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.whiteColor()
        searchBar.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSearchResponse:", name: Methods.PhotoSearchMethod, object: nil)
    }
    
    func search()
    {
        FlickrLoader.sharedInstance.loadPhotos(forSearchString: searchBar.text)
    }
    
    func handleSearchResponse(notification: NSNotification)
    {
        model.removeAll()
        if let photos = extractPhotosFromResponseNotification(notification) {
            let lessPhotos = photos[1..<10]
            for photo in lessPhotos {
                model.append(FlickrPhoto(flickrAPIResponsePhoto: photo as NSDictionary))
            }
            collectionView.reloadData()
        }
    }
    
    func extractPhotosFromResponseNotification(notification: NSNotification) -> [NSDictionary]?
    {
        if let response = notification.userInfo?[UserInfoKeys.DataKey] as? Dictionary<String, AnyObject> {
            if let photos = response["photos"]?["photo"] as? [NSDictionary] {
                return photos
            }
        }
        return nil
    }
    
        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            if segue.identifier == "go"
            {
                if let destinationVC = segue.destinationViewController as? MapViewController {
                    destinationVC.flickrPhoto = sender as? FlickrPhoto
                }
            }
        }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println(Storyboard.locationSegue)
        self.performSegueWithIdentifier("go", sender: model[indexPath.row])
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Storyboard.photoCellIdentifier, forIndexPath: indexPath) as! FlickrPhotoCell
        cell.imageView.image = model[indexPath.row].loadImage()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return model.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        search()
    }
}


