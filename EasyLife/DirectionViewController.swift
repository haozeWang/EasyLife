//
//  DirectionViewController.swift
//  EasyLife
//
//  Created by Meng Wang on 3/10/17.
//  Copyright © 2017 Haoze Wang. All rights reserved.
//

import UIKit
import MapKit

class DirectionViewController: UIViewController, UITabBarDelegate{

    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var sourceLabel: UILabel!

    @IBOutlet weak var destLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var tabBar: UITabBar!
    
    
    // tab bar buttons to choose the travel vehicle
    @IBOutlet weak var driveButton: UITabBarItem!
    @IBOutlet weak var transitButton: UITabBarItem!
    @IBOutlet weak var walkButton: UITabBarItem!
    @IBOutlet weak var cycleButton: UITabBarItem!
    
    
    // protocol to set location for the schedule
    var scheduleSetLocationProtocolDelegate: ScheduleSetLocationProtocol? = nil
    
    // whether the view is opened by a Schedule View Controller
    var fromScheduleVC = false
    
    
    // coordinates of source and destination
    var sourceCoordinate: CLLocationCoordinate2D? = nil
    var destCoordinate: CLLocationCoordinate2D? = nil
    
    // region for search
    var searchRegion: MKCoordinateRegion? = nil
    
    // current travel mode
    var currentTravelMode = "driving"
    
    // routes get from Google Map API
    var routes = [AnyObject]()
    
    // selected route
    var selectedRoute = MyRoute()
    
    // record the time and distance information of routes of the current travel mode
    var myRoutes = [MyRoute]()
    
    
    // This scrollView is used to show some detailed information of the current route
    var scrollView: UIScrollView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize the UI
        self.view.layer.backgroundColor = UIColor(red: 65/255, green: 105/255, blue: 225/255, alpha: 1).cgColor
        backButton.layer.borderColor = UIColor.clear.cgColor
        self.sourceLabel.layer.backgroundColor = UIColor(white: 1, alpha: 0.1).cgColor
        self.sourceLabel.textColor = UIColor.white
        self.destLabel.layer.backgroundColor = UIColor(white: 1, alpha: 0.1).cgColor
        self.destLabel.textColor = UIColor.white
        
        
        
        // add tabBarButton actions to choose the mode of travel
        tabBar.delegate = self

        mapView.delegate = self
        
        // select driveButton by default
        tabBar.selectedItem = driveButton
        tabBar(self.tabBar, didSelect: driveButton)
        
        
        // when tab on the source/dest label, open another view controller to let the user choose the location
        sourceLabel.isUserInteractionEnabled = true
        let sourceGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tabSourceLabel))
        sourceLabel.addGestureRecognizer(sourceGestureRecognizer)
        
        destLabel.isUserInteractionEnabled = true
        let destGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tabDestLabel))
        destLabel.addGestureRecognizer(destGestureRecognizer)
        
        // scrollview
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 591, width: 375, height: 80))
        scrollView!.backgroundColor = UIColor.init(white: 1, alpha: 0.2)
        scrollView!.isPagingEnabled = true
        scrollView!.isScrollEnabled = true
        scrollView!.isUserInteractionEnabled = true
        scrollView!.delegate = self
        view.addSubview(scrollView!)
        
        
        
         mapView.mapType = .satellite
    }
    

    // dismiss the current view controller
    @IBAction func dismissSelf(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // when the source label is clicked
    func tabSourceLabel() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectLocationVC") as! SelectLocationViewController
        vc.type = "source"
        vc.searchRegion = self.searchRegion
        vc.locationSearchDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    // when the destLabel is clicked
    func tabDestLabel() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectLocationVC") as! SelectLocationViewController
        vc.type = "destination"
        vc.searchRegion = self.searchRegion
        vc.locationSearchDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    
    
    // change the travel mode by changing the selected tabbarItem
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == driveButton {
            getDirections(mode: "driving")
            currentTravelMode = "driving"
        } else if item == walkButton {
            getDirections(mode: "walking")
            currentTravelMode = "walking"
        } else if item == cycleButton {
            getDirections(mode: "bicycling")
            currentTravelMode = "bicycling"
        } else if item == transitButton {
            getDirections(mode: "transit")
            currentTravelMode = "transit"
        }
    }
    
    
    
    // draw the route on the map
    /// - Attribution: https://developers.google.com/maps/documentation/directions/intro#TravelModes
    func getDirections(mode: String) {
        var googleMapUrl = "https://maps.googleapis.com/maps/api/directions/json?"
        let key = "AIzaSyBuh-vmZk4PPOCO1c6ELDcxkntiLWHy4tE"
        
        print("+++++++")
        // source location
        let sourceLatitude = self.coordinateDegreeString(degree: "\(sourceCoordinate?.latitude)")
        let sourceLongitude = self.coordinateDegreeString(degree: "\(sourceCoordinate?.longitude)")
        
        googleMapUrl += "origin=\(sourceLatitude),\(sourceLongitude)"
        
        // destination
        let destLatitude = self.coordinateDegreeString(degree: "\(destCoordinate?.latitude)")
        let destLongitude = self.coordinateDegreeString(degree: "\(destCoordinate?.longitude)")
        googleMapUrl += "&destination=\(destLatitude),\(destLongitude)"
        
        // mode
        googleMapUrl += "&mode=\(mode)"
        
        // alternative
        googleMapUrl += "&alternatives=true"
        
        googleMapUrl += "&key=\(key)"
        
        print(googleMapUrl)
        
        // get the route using google map API
        SharedNetworking.networkInstance.googleMapDirectionResults(url: googleMapUrl) {
            (routes, success) -> Void in
            print("-------------")
            if routes.count>0 {
                self.routes = routes
                DispatchQueue.main.async {
                    self.updateScrollView()
                }
                self.drawRoute(routeIndex: 0)
            }
        }

    }
 
    
    // draw the polyline of the selected route
    func drawRoute(routeIndex: Int) {
        if let route = routes[routeIndex] as? [String: AnyObject] {
            if let overview_polyline = route["overview_polyline"] as? [String: AnyObject] {
                if let encodedPolyline = overview_polyline["points"] as? String {
                    
                    let polyline = DecodePolyline.polyline(withEncodedString: encodedPolyline)
                    
                    DispatchQueue.main.async {
                        self.mapView.removeOverlays(self.mapView.overlays)
                        
                        self.mapView.add(polyline!)
                        // set the new map rect
                        let newMapSize = MKMapSize(width: polyline!.boundingMapRect.size.width*1.5,
                                                   height: polyline!.boundingMapRect.size.height*1.5)
                        let newMapOriginX = polyline!.boundingMapRect.origin.x
                            + polyline!.boundingMapRect.size.width/2
                            - newMapSize.width/2
                        let newMapOriginY = polyline!.boundingMapRect.origin.y
                            + polyline!.boundingMapRect.size.height/2
                            - newMapSize.height/2
                        let newMapOrigin = MKMapPoint(x: newMapOriginX, y: newMapOriginY)
                        let newMapRect = MKMapRect(origin: newMapOrigin, size: newMapSize)
                        self.mapView.setVisibleMapRect(newMapRect, animated: true)
                    }
                    
                }
            }
        }

    }
    
    
    
    // when the travel mode is changed, update the scrollview
    func updateScrollView() {
        let n = routes.count
        
        if let scrollView = self.scrollView {
            for view in scrollView.subviews {
                view.removeFromSuperview()
            }
        }
        
        scrollView?.contentSize = CGSize(width: 375*n, height: 80)
        scrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    
        
        print(n)
        
        myRoutes.removeAll()
        
        for i in 0..<n {
            guard let route = routes[i] as? [String: AnyObject] else {  return}
            guard let legs = route["legs"] as? [AnyObject] else {   return}
            guard let leg = legs[0] as? [String: AnyObject] else {  return}
            // time
            guard let duration = leg["duration"] as? [String: AnyObject] else { return}
            guard let timeText = duration["text"] as? String,
                let timeValue = duration["value"] as? Int else { return}
            let timeLabel = UILabel(frame: CGRect(x: 20 + 375 * i, y: 0, width: 200, height: 35))
            timeLabel.text = "Time: \(timeText)"
            timeLabel.backgroundColor = UIColor.clear
            timeLabel.textColor = UIColor.white
            timeLabel.font = UIFont.boldSystemFont(ofSize: 20)
            print(timeText)
            
            // distance
            guard let distance = leg["distance"] as? [String: AnyObject] else { return}
            guard let distanceText = distance["text"] as? String,
                let distanceValue = distance["value"] as? Int   else { return}
            let distanceLabel = UILabel(frame: CGRect(x: 20 + 375 * i, y: 30, width: 200, height: 35))
            distanceLabel.text = "Distance: \(distanceText)"
            distanceLabel.backgroundColor = UIColor.clear
            distanceLabel.textColor = UIColor.orange
            distanceLabel.font = UIFont.boldSystemFont(ofSize: 20)
            print(distanceText)
            
            // add the information into myRoutes
            myRoutes.append(MyRoute(time: timeValue, timeText: timeText, distance: distanceValue, distanceText: distanceText))
            
            if i == 0 {
                selectedRoute = myRoutes[0]
            }
            
            
            // add a confirm button on each page of the scrollView
            // - Attribution: http://stackoverflow.com/questions/35550966/swift-add-show-action-to-button-programmatically
            let confirmButton = UIButton(frame: CGRect(x: 300 + 375 * i, y: 15, width: 50, height: 50))
            confirmButton.setBackgroundImage(UIImage(named: "confirm"), for: .normal)
            if fromScheduleVC == true {
                confirmButton.addTarget(self, action: #selector(self.sendDataToSchedule), for: UIControlEvents.touchUpInside)
            } else {
                print("click")
            }
            
            DispatchQueue.main.async {
                self.scrollView?.addSubview(timeLabel)
                self.scrollView?.addSubview(distanceLabel)
                self.scrollView?.addSubview(confirmButton)
            }
        }
        
    }
    
    
    
    // convert the coordinate degree into string
    func coordinateDegreeString(degree: String) -> String {
        var result = degree
        print("degree:\(degree)")
        let start = result.index(result.startIndex, offsetBy: 9)
        let end = result.index(result.endIndex, offsetBy: -1)
        let range = start..<end
        print(result)
        result = result.substring(with: range)
        return result
    }
    
    
    // send data back to schedule view
    func sendDataToSchedule() {
        // source location
        let sourceLatitude = self.coordinateDegreeString(degree: "\(sourceCoordinate?.latitude)")
        let sourceLongitude = self.coordinateDegreeString(degree: "\(sourceCoordinate?.longitude)")
        
        // destination
        let destLatitude = self.coordinateDegreeString(degree: "\(destCoordinate?.latitude)")
        let destLongitude = self.coordinateDegreeString(degree: "\(destCoordinate?.longitude)")
        
        if scheduleSetLocationProtocolDelegate != nil {
            scheduleSetLocationProtocolDelegate!.updateLocation(sourceLat: sourceLatitude,
                                                                sourceLon: sourceLongitude,
                                                                destLat: destLatitude,
                                                                destLon: destLongitude,
                                                                sourceName: self.sourceLabel.text!,
                                                                destName: self.destLabel.text!,
                                                                expectedTime: selectedRoute.time)
            let presentingViewController = self.presentingViewController
            self.dismiss(animated: true) {
                presentingViewController?.dismiss(animated: false, completion: nil)
            }
        }
    }
}


// customize the mapview
extension DirectionViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.lineWidth = 5.0
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
}


// update the source or destination and update the route
extension DirectionViewController: LocationSearchProtocol {
    func updateDirection(placemark: MKPlacemark, locationType: String) {
        if locationType == "source" {
            sourceLabel.text = placemark.name
            sourceCoordinate = placemark.coordinate
        } else {
            destLabel.text = placemark.name
            destCoordinate = placemark.coordinate
        }
        self.getDirections(mode: currentTravelMode)
    }
}


// when the scrollView is scrolled, update the selected route
extension DirectionViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(selectedRoute.distanceText)
        let pageNumber: Int = Int(self.scrollView!.contentOffset.x / self.scrollView!.frame.width)
        selectedRoute = myRoutes[pageNumber]
        
        // draw route
        self.drawRoute(routeIndex: pageNumber)
        
    }
}
