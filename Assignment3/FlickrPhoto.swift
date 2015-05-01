//
//  FlickrPhoto.swift
//  Assignment3
//
//  Created by admin on 28/04/15.
//  Copyright (c) 2015 Chip Digital GmbH. All rights reserved.
//

import UIKit
import MapKit

class FlickrPhoto
{
    var farm: Int = 0
    var id: String  = ""
    var server: String  = ""
    var secret: String  = ""
    var title: String  = ""
    var image: UIImage?
    
    init(flickrAPIResponsePhoto: NSDictionary)
    {
        id = flickrAPIResponsePhoto["id"] as! String
        farm = flickrAPIResponsePhoto["farm"] as! Int
        title = flickrAPIResponsePhoto["title"] as! String
        server = flickrAPIResponsePhoto["server"] as! String
        secret = flickrAPIResponsePhoto["secret"] as! String
    }
    
    func loadImage() -> UIImage
    {
        let url = NSURL(string: photoUrl)
        let data = NSData(contentsOfURL: url!)
        image = UIImage(data: data!)!
        return image!
    }
    
    var photoUrl: String
    {
        get {
            return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_t.jpg";
        }
    }
}
