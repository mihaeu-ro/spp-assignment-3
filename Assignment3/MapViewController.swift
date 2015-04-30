//
//  MapViewController.swift
//  Assignment3
//
//  Created by admin on 28/04/15.
//  Copyright (c) 2015 Chip Digital GmbH. All rights reserved.
//

import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var flickrPhoto: FlickrPhoto? {
        didSet {
            FlickrLoader.sharedInstance.locationForPhoto(flickrPhoto!.id)
        }
    }
    
    private let locationManager = CLLocationManager()
    
    private let myAnnotation = MKPointAnnotation()
    private let photoAnnotation = MKPointAnnotation()
    
    var myLocation: CLLocationCoordinate2D? {
        didSet {
            updateDistanceLabel()
        }
    }
    var photoLocation: CLLocationCoordinate2D? {
        didSet {
            updatePhotoAnnotations()
            updateDistanceLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSearchResponse:", name: Methods.PhotoLocationMethod, object: nil)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView?.showsUserLocation = true
    }
    
    func handleSearchResponse(notification: NSNotification)
    {
        if let response = notification.userInfo?[UserInfoKeys.DataKey] as? Dictionary<String, AnyObject> {
            if let photoInfo = response["photo"] as? Dictionary<String, AnyObject> {
                if let location = photoInfo["location"] as? Dictionary<String, AnyObject> {
                    var latitude: Double = NSString(string: location["latitude"] as! String).doubleValue
                    var longitude: Double = NSString(string: location["longitude"] as! String).doubleValue
                    photoLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    {
        if let firstLocation = locations.first as? CLLocation {
            let location = CLLocationCoordinate2D(latitude: firstLocation.coordinate.latitude, longitude: firstLocation.coordinate.longitude)
            myLocation = location
        }
    }
    
    func updatePhotoAnnotations()
    {
        if photoLocation != nil {
            mapView.setCenterCoordinate(photoLocation!, animated: true)
            let region = MKCoordinateSpanMake (1000, 1000)
            
            mapView.removeAnnotation(photoAnnotation)
            photoAnnotation.coordinate = CLLocationCoordinate2D(latitude: photoLocation!.latitude, longitude: photoLocation!.longitude)
            photoAnnotation.title = "Photo"
            mapView.addAnnotation(photoAnnotation)
        }
    }
    
    func updateDistanceLabel()
    {
        if myLocation != nil {
            if photoLocation != nil {
                distanceLabel.text = "Photo was taken \(CLLocation.distanceInMeters(myLocation!, to: photoLocation!)) km away.";
                distanceLabel.hidden = false
            } else {
                distanceLabel.hidden = true
            }
        } else {
            distanceLabel.hidden = true
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!)
    {
        println("Error while updating location: \(error.localizedDescription)")
    }
}

extension CLLocation
{
    class func distanceInMeters(from: CLLocationCoordinate2D, to:CLLocationCoordinate2D) -> CLLocationDistance
    {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return round(from.distanceFromLocation(to) / 1000)
    }
}

