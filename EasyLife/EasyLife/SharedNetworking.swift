//
//  SharedNetworking.swift
//  hello map
//
//  Created by Meng Wang on 3/9/17.
//  Copyright © 2017 Meng Wang. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

// singleton class
class SharedNetworking {
    
    static let networkInstance = SharedNetworking()
    
    
    
    // search directions using google map api
    /// - Attribution: https://developers.google.com/maps/documentation/directions/intro#traffic-model
    func googleMapDirectionResults(url: String, completion:@escaping ([AnyObject], Bool) -> Void) {
        
        // check if network is connected
        if !ReachAbility.isInternetAvailable() {
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // initialize the results
        var routes = [AnyObject]()
        
        // Transform the `url` parameter argument to a `URL`
        guard let url = NSURL(string: url) else {
            completion(routes, false)
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            return
        }
        
        
        
        // Create a url session
        let urlconfig = URLSessionConfiguration.default
        let session = URLSession(configuration: urlconfig)
        
        // Create a data task
        let task = session.dataTask(with: url as URL, completionHandler: { (data, response, error) -> Void in
            
            // Print out the response (for debugging purpose)
            print("Response: \(response)")
            
            
            // Ensure there were no errors returned from the request
            guard error == nil else {
                print("error")
                completion(routes, false)
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                return
            }
            
            // Ensure there is data and unwrap it
            guard let data = data else {
                completion(routes, false)
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                return
            }
            
            // We received raw data, print it out for debugging
            // It needs to be converted to JSON
            print("Raw data: \(data)")
            
            // Serialize the raw data into JSON using `NSJSONSerialization`.  The "do-let" is
            // part of
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print("-------------------------")
                print(json)
                
                
                // Cast JSON as an array of dictionaries
                guard let jsonTemp = json as? [String: AnyObject] else {
                    completion(routes, false)
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    return
                }
                
                guard let tempRoutes = jsonTemp["routes"] as? [AnyObject] else {
                    completion(routes, false)
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    return
                }
                
                routes = tempRoutes
                
                completion(routes, true)
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            } catch {
                completion(routes, false)
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                return
            }
        })
        // Tasks start off in suspended state, we need to kick it off
        task.resume()
    }
    
    
    
    
    // get detailed information about locations using google places API
    /// - Attribution: https://developers.google.com/places/web-service/details
    func googlePlaceSearchResults(latitute: String, longitute: String, name: String, completion:@escaping ([String: AnyObject], Bool) -> Void) {
        
        // initialize the results
        var result = [String: AnyObject]()
        
        
        // check if network is connected
        if !ReachAbility.isInternetAvailable() {
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var placeSearchUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        
        placeSearchUrl += "location=\(latitute),\(longitute)"
        
        placeSearchUrl += "&rankby=distance"
        
        placeSearchUrl += "&keyword=\(name)"
        
        let key = "AIzaSyBIMD_Nulnv7yw4OaKa-rEAqvI3I_hAv4E"
        
        placeSearchUrl += "&key=\(key)"

        
        // Transform the `url` parameter argument to a `URL`
        guard let url = NSURL(string: placeSearchUrl) else {
            completion(result, false)
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            return
        }
        
        
        
        // Create a url session
        let urlconfig = URLSessionConfiguration.default
        let session = URLSession(configuration: urlconfig)
        
        // Create a data task
        let task = session.dataTask(with: url as URL, completionHandler: { (data, response, error) -> Void in
            
            // Print out the response (for debugging purpose)
            print("Response: \(response)")
            
            
            // Ensure there were no errors returned from the request
            guard error == nil else {
                print("error")
                completion(result, false)
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                return
            }
            
            // Ensure there is data and unwrap it
            guard let data = data else {
                completion(result, false)
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                return
            }
            
            // We received raw data, print it out for debugging
            // It needs to be converted to JSON
            print("Raw data: \(data)")
            
            // Serialize the raw data into JSON using `NSJSONSerialization`.  The "do-let" is
            // part of
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print("-------------------------")
                print(json)
                
                
                // Cast JSON as an array of dictionaries
                guard let jsonTemp = json as? [String: AnyObject] else {
                    completion(result, false)
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    return
                }
                
                guard let placeResults = jsonTemp["results"] as? [AnyObject] else {
                    completion(result, false)
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    return
                }
                
                
                
                if placeResults.count == 0 {
                    print("-------------------------")
                    print(placeResults)
                    completion(result, false)
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    return
                }
                
                // use the first result in default
                guard let placeResult = placeResults[0] as? [String: AnyObject] else {
                    completion(result, false)
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    return
                }
                
                // get the place ID
                guard let placeID = placeResult["place_id"] as? String else {
                    completion(result, false)
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    return
                }
                
                // search the detail
                self.placeDetails(placeID: placeID) { (detailResult, success) -> Void in
                    result = detailResult
                    completion(result, success)
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                }
                
                
            } catch {
                completion(result, false)
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                return
            }
        })
        // Tasks start off in suspended state, we need to kick it off
        task.resume()
    }

    
    
    
    // search a detailed place using place id provided by google
    func placeDetails(placeID: String, completion:@escaping ([String: AnyObject], Bool) -> Void) {
        
        // initialize the results
        var result = [String: AnyObject]()
        
        
        // check if network is connected
        if !ReachAbility.isInternetAvailable() {
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var placeDetailUrl = "https://maps.googleapis.com/maps/api/place/details/json?"
        
        placeDetailUrl += "placeid=\(placeID)"
        
        let key = "AIzaSyBIMD_Nulnv7yw4OaKa-rEAqvI3I_hAv4E"
        
        placeDetailUrl += "&key=\(key)"
        
        
        // Transform the `url` parameter argument to a `URL`
        guard let url = NSURL(string: placeDetailUrl) else {
            completion(result, false)
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            return
        }
        
        
        
        // Create a url session
        let urlconfig = URLSessionConfiguration.default
        let session = URLSession(configuration: urlconfig)
        
        // Create a data task
        let task = session.dataTask(with: url as URL, completionHandler: { (data, response, error) -> Void in
            
            // Print out the response (for debugging purpose)
            print("Response: \(response)")
            
            
            // Ensure there were no errors returned from the request
            guard error == nil else {
                print("error")
                completion(result, false)
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                return
            }
            
            // Ensure there is data and unwrap it
            guard let data = data else {
                completion(result, false)
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                return
            }
            
            // We received raw data, print it out for debugging
            // It needs to be converted to JSON
            print("Raw data: \(data)")
            
            // Serialize the raw data into JSON using `NSJSONSerialization`.  The "do-let" is
            // part of
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print("-------------------------")
                print(json)
                
                
                // Cast JSON as an array of dictionaries
                guard let jsonTemp = json as? [String: AnyObject] else {
                    completion(result, false)
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    return
                }
                
                
                // use the first result in default
                guard let placeResult = jsonTemp["result"] as? [String: AnyObject] else {
                    completion(result, false)
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    return
                }
                
                result = placeResult
                
                completion(result, true)
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            } catch {
                completion(result, false)
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                return
            }
        })
        // Tasks start off in suspended state, we need to kick it off
        task.resume()

    }
    
    
    
    
    
    // download Image
    func downloadImage(urlString: String, completion:@escaping (NSData, Bool) -> Void) {
        
        // check if network is connected
        if !ReachAbility.isInternetAvailable() {
            return
        }
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // initialize the results
        var imageData = NSData()
        
        // Transform the `url` parameter argument to a `URL`
        guard let url = URL(string: urlString) else {
            completion(imageData, false)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return
        }
        
        // Create a url session
        let urlconfig = URLSessionConfiguration.default
        let session = URLSession(configuration: urlconfig)
        
        // Create a data task
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            
            // Print out the response (for debugging purpose)
            print("Response: \(response)")
            
            
            // Ensure there were no errors returned from the request
            guard error == nil else {
                print("error")
                completion(imageData, false)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            
            // Ensure there is data and unwrap it
            guard let tempData = data as NSData? else {
                completion(imageData, false)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            
            guard let _ = UIImage(data: tempData as Data) else {
                completion(imageData, false)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            
            imageData = tempData
            completion(imageData, true)
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
            
            
        })
        // Tasks start off in suspended state, we need to kick it off
        task.resume()
    }

    
}
