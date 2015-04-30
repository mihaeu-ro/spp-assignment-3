//
//  InstagramLoader.swift
//  Assignment3
//
//  Created by Andreas Partenhauser on 01.04.15.
//  Copyright (c) 2015 Chip Digital GmbH. All rights reserved.
//

import UIKit
import Alamofire

public class FlickrLoader: NSObject
{
    let manager = Alamofire.Manager.sharedInstance
    
    public class var sharedInstance: FlickrLoader
    {
        struct Singleton
        {
            static let instance = FlickrLoader()
        }
        
        return Singleton.instance
    }
    
    /**
        Will load photos from Flickr
    
        https://www.flickr.com/services/api/flickr.photos.search.html
    */
    func loadPhotos(forSearchString searchString: String)
    {
        let parameter: [String: String] = [
            ParameterName.ApiKey:           FlickrAPI.FlickrAPIKey,
            ParameterName.Method:           Methods.PhotoSearchMethod,
            ParameterName.Format:           FlickrAPI.FormatNameJson,
            ParameterName.Text:             searchString,
            ParameterName.NoJsonCallback:   FlickrAPI.NoJsonCallBackValue,
            ParameterName.Geo:              FlickrAPI.GeoForced
        ]
        
        let urlString = urlWithParameter(parameter as Dictionary<String, String>)
        
        if let url = NSURL(string: urlString) {
            loadRequest(url, notifificationName: Methods.PhotoSearchMethod)
        }
    }
    
    /**
        Gets the latitude and longitude of a photo on Flickr
    
        https://www.flickr.com/services/api/flickr.photos.geo.getLocation.html
    */
    func locationForPhoto(photoId: String)
    {
        let parameter: [String: String] = [
            ParameterName.ApiKey:           FlickrAPI.FlickrAPIKey,
            ParameterName.Method:           Methods.PhotoLocationMethod,
            ParameterName.Format:           FlickrAPI.FormatNameJson,
            ParameterName.PhotoId:          photoId,
            ParameterName.NoJsonCallback:   FlickrAPI.NoJsonCallBackValue
        ]
        
        let urlString = urlWithParameter(parameter)
        
        if let url = NSURL(string: urlString) {
            loadRequest(url, notifificationName: Methods.PhotoLocationMethod)
        }
    }
    
    /**
        Sends the actual request using Alamofire.
    */
    private func loadRequest(url: NSURL, notifificationName: String)
    {
        manager
            .request(NSURLRequest(URL: url))
            .responseJSON(options: NSJSONReadingOptions.AllowFragments) { (_, _, data, _) -> Void in
                self.handleResponse(data as! Dictionary<String, AnyObject>, notifificationName: notifificationName)
            }
    }
    
    /**
        Posts a notification with the response object.
    */
    private func handleResponse(data: Dictionary<String, AnyObject>, notifificationName: String)
    {
        NSNotificationCenter
            .defaultCenter()
            .postNotificationName(notifificationName, object: nil, userInfo: [UserInfoKeys.DataKey: data])
    }
    
    /**
        Converts a Dictionary into a URL String like BASE_URL?foo=bar&foo2=bar2
    */
    private func urlWithParameter(parameter: Dictionary<String, String>) -> String
    {
        var urlString = "\(FlickrAPI.FlickrRestBaseUrl)?"
        for (parameterName, parameterValue) in parameter {
            urlString = urlString + parameterName + "=" + parameterValue + "&"
        }
        return urlString
    }
}

struct FlickrAPI
{
    static let FlickrRestBaseUrl = "https://api.flickr.com/services/rest/"
    static let FlickrAPIKey = "fd2b03f1a74de7a45ebd5c1d54bc2789"
    static let FlickrSecretKey = "c63b8995ba8f0380"
    
    static let FormatNameJson = "json"
    static let NoJsonCallBackValue = "1"
    static let GeoForced = "1"
}

struct UserInfoKeys
{
    static let DataKey = "DataKey"
}

struct Methods
{
    static let PhotoSearchMethod = "flickr.photos.search"
    static let PhotoLocationMethod = "flickr.photos.geo.getLocation"
    static let PhotoInfoMethod = "flickr.photos.getInfo"
}

struct ParameterName
{
    static let ApiKey = "api_key"
    static let Method = "method"
    static let Text = "text"
    static let Format = "format"
    static let PhotoId = "photo_id"
    static let NoJsonCallback = "nojsoncallback"
    static let Geo = "has_geo"
}
