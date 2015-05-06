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
    // Identifiers
    static let PhotoCellIdentifier = "MyCell"
    static let AnnotationViewReuseIdentifier = "annotationReuseId"
    
    // Selectors
    static let SearchResponseSelector = Selector("handleSearchResponse:")
    
    // Segues
    static let LocationSegue = "go"
    static let ShowImageSegue = "Show Image"
    
    static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
}

class FlickrPhotoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate
{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView! {
        didSet {
            spinner.hidesWhenStopped = true
        }
    }
    
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Storyboard.SearchResponseSelector, name: Methods.PhotoSearchMethod, object: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.LocationSegue
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
    
    @IBAction func clear(sender: AnyObject)
    {
        let deleteIndexPath = collectionView.indexPathsForVisibleItems()[0] as! NSIndexPath
        collectionView.deleteItemsAtIndexPaths([deleteIndexPath])
    }
    
    // TODO: Ask how to delete the contents of a collection view
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
            spinner.stopAnimating()
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
        self.performSegueWithIdentifier(Storyboard.LocationSegue, sender: currentFlickrPhoto)
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Storyboard.PhotoCellIdentifier, forIndexPath: indexPath) as! FlickrPhotoCell
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
        spinner.startAnimating()
        searchForFlickrPhotos()
    }
}


