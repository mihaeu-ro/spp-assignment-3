//
//  MapViewController.swift
//  Assignment3
//
//  Created by admin on 28/04/15.
//  Copyright (c) 2015 Chip Digital GmbH. All rights reserved.
//

import MapKit
import XCGLogger

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate
{
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
            mapView.showsUserLocation = true
        }
    }
    @IBOutlet weak var distanceLabel: UILabel!
    
    var flickrPhoto: FlickrPhoto? {
        didSet {
            FlickrLoader.sharedInstance.locationForPhoto(flickrPhoto!.id)
        }
    }
    
    private let locationManager = CLLocationManager()
    private var photoAnnotation = MKPointAnnotation() // FlickrPhotoMarker?

    var myLocation: CLLocationCoordinate2D? {
        didSet {
            updateDistanceLabel()
        }
    }
    var photoLocation: CLLocationCoordinate2D = CLLocationCoordinate2D() {
        didSet {
            updatePhotoAnnotation()
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
    
    func updatePhotoAnnotation()
    {
        mapView.setCenterCoordinate(photoLocation, animated: true)
        
        mapView.removeAnnotation(photoAnnotation)
        photoAnnotation.coordinate = CLLocationCoordinate2D(latitude: photoLocation.latitude, longitude: photoLocation.longitude)
        photoAnnotation.title = flickrPhoto?.title
        mapView.addAnnotation(photoAnnotation)
        mapView.showAnnotations([photoAnnotation], animated: true)

        // TODO: Zoom out to show both coordinates
        
//        let startPoint = MKMapPoint(
//            x: min(myLocation!.longitude, photoLocation.longitude),
//            y: min(myLocation!.latitude, photoLocation.latitude)
//        )
//        let zoomSize = MKMapSize(
//            width: abs(myLocation!.longitude - photoLocation.longitude),
//            height: abs(myLocation!.latitude - photoLocation.latitude)
//        )
//        var zoomRect = MKMapRect(origin: startPoint, size: zoomSize);
//        mapView.setVisibleMapRect(zoomRect, animated: true)
    }
    
    func updateDistanceLabel()
    {
        if myLocation != nil {
            distanceLabel.text = "Photo was taken \(CLLocation.distanceInMeters(myLocation!, to: photoLocation)) km away.";
        }
    }
    
    // MARK: CLLocationManager
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    {
        if let firstLocation = locations.first as? CLLocation {
            let location = CLLocationCoordinate2D(latitude: firstLocation.coordinate.latitude, longitude: firstLocation.coordinate.longitude)
            myLocation = location
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!)
    {
        log.error("Error while updating location: \(error.localizedDescription)")
    }
    
    // MARK: MKMapViewDelegate

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Storyboard.AnnotationViewReuseIdentifier)
        
        if (view == nil) {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Storyboard.AnnotationViewReuseIdentifier)
            view.canShowCallout = true
        } else {
            view.annotation = annotation
        }
        
        view.leftCalloutAccessoryView = UIImageView(frame: Storyboard.LeftCalloutFrame)
        view.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
        
        return view
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if let thumbnailImageView = view.leftCalloutAccessoryView as? UIImageView {
            let url = NSURL(string: flickrPhoto!.thumbnailUrl)
            if let imageData = NSData(contentsOfURL: url!) { // TODO: This should be in a separate thread
                if let image = UIImage(data: imageData) {
                    thumbnailImageView.image = image
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        performSegueWithIdentifier(Storyboard.ShowImageSegue, sender: flickrPhoto)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == Storyboard.ShowImageSegue {
            if let photo = (sender as? FlickrPhoto) {
                if let ivc = segue.destinationViewController as? ImageViewController {
                    let imageURL = NSURL(string: flickrPhoto!.photoUrl)
                    ivc.imageURL = imageURL
                    ivc.title = flickrPhoto?.title
                }
            }
        }
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

