//
//  FlickrPhotoMarker.swift
//  Assignment3
//
//  Created by admin on 30/04/15.
//  Copyright (c) 2015 Chip Digital GmbH. All rights reserved.
//

import MapKit

class FlickrPhotoMarker: MKPointAnnotation
{
    private var flickrPhoto: FlickrPhoto?
    private var photoLocation: CLLocationCoordinate2D?
    
    init(flickrPhoto: FlickrPhoto, photoLocation: CLLocationCoordinate2D)
    {
        super.init()
        
        self.flickrPhoto = flickrPhoto
        self.photoLocation = photoLocation
        
        self.coordinate = photoLocation
        self.title = flickrPhoto.title ?? "Photo"
    }
}