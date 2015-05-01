//
//  FlickrPhotoViewController.swift
//  Assignment-3
//
//  Created by admin on 29/04/15.
//  Copyright (c) 2015 mihaeu. All rights reserved.
//

import UIKit
import XCGLogger

struct Storyboard
{
    private static let locationSegue = "go"
    private static let photoCellIdentifier = "MyCell"
    private static let searchResponseSelector = Selector("handleSearchResponse:")
}

class FlickrPhotoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate
{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var model: [FlickrPhoto] = [FlickrPhoto]()
    
    // MARK: UIViewController
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.whiteColor()
        
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Storyboard.searchResponseSelector, name: Methods.PhotoSearchMethod, object: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.locationSegue
        {
            if let flickrPhoto = sender as? FlickrPhoto {
                log.info("Clicked photo with ID: " + flickrPhoto.id)
                if let destinationVC = segue.destinationViewController as? MapViewController {
                    destinationVC.flickrPhoto = flickrPhoto
                }
            }
        }
    }
    
    // MARK: Flickr API
    
    // TODO: Ask how to delete the contents of a collection view
    /**
        EXPERIMENTAL
        DOESN'T WORK
    */
    @IBAction func clear(sender: AnyObject)
    {
        let deleteIndexPath = collectionView.indexPathsForVisibleItems()[0] as! NSIndexPath
        collectionView.deleteItemsAtIndexPaths([deleteIndexPath])
    }
    
    func searchForFlickrPhotos()
    {
        log.info("Searching for: " + self.searchBar.text)
        FlickrLoader.sharedInstance.loadPhotos(forSearchString: searchBar.text, perPage: 10)
    }
    
    func handleSearchResponse(notification: NSNotification)
    {
        if let photos = extractPhotosFromResponseNotification(notification) {
            for photo in photos {
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
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let currentFlickrPhoto = model[indexPath.row]
        self.performSegueWithIdentifier(Storyboard.locationSegue, sender: currentFlickrPhoto)
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
        searchForFlickrPhotos()
    }
}


