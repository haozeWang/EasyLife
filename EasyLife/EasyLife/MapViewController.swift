//
//  ViewController.swift
//  hello map
//
//  Created by Meng Wang on 3/8/17.
//  Copyright © 2017 Meng Wang. All rights reserved.
//

import UIKit
import MapKit


/// - Attribution: https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/
class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    // search controller
    var locationSearchController: UISearchController? = nil
    
    // protocol to set location for a schedule
    var scheduleSetLocationProtocolDelegate: ScheduleSetLocationProtocol? = nil
    
    // selected destination location
    var selectedPin: MKPlacemark? = nil
    
    // current location
    var currentLocation: CLLocation? = nil
    
    // show a summary information of the selected location at the bottom of the view controller
    // tapping the view will open a detail view controller showing more details about the view controller
    var bottomView: UIView? = nil
    var bottomLocationNameLabel: UILabel? = nil
    var bottomLocationSubtitleLabel: UILabel? = nil
    var bottomImageView: UIImageView? = nil
    
    // detail information of the location
    var locationDetail: [String: AnyObject]? = nil
    
    // indicator view
    var activity = UIActivityIndicatorView()
    var whiteView = UIView()
    
    // whether we come to this viewController from a schedule view controller
    var fromScheduleVC = false
    
    @IBOutlet weak var backButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize the location search table and search controller
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTableViewController") as! LocationSearchTableViewController
        
        locationSearchTable.mapView = mapView
        locationSearchTable.mapSearchProtocolDelegate = self
        
        locationSearchController = UISearchController(searchResultsController: locationSearchTable)
        locationSearchController?.searchResultsUpdater = locationSearchTable
        
        
        
        // configure the search bar, and embed it within the navigation bar
        let searchBar = locationSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        self.navigationItem.titleView = locationSearchController?.searchBar
        locationSearchController?.searchBar.isUserInteractionEnabled = false
        
        // configure the uisearch controller appearence
        locationSearchController?.hidesNavigationBarDuringPresentation = false
        locationSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        mapView.mapType = .satellite
        
        // initialize the indicator view
        whiteView = UIView(frame: self.view.frame)
        whiteView.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
        whiteView.isUserInteractionEnabled = false
        self.view.addSubview(whiteView)
        
        
        activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activity.center = whiteView.center
        whiteView.addSubview(activity)
        activity.startAnimating()
        
        
        
        
        // initialize the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        // initialize the bottom view
        initBottomView()
        
        // add a dismiss button if this view controller comes from a schedule view controller
        if fromScheduleVC == false {
            backButton.isHidden = true
            backButton.isUserInteractionEnabled = false
        }
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }


    
    
    
    
    // initialize the bottom view
    func initBottomView() {
        // bottom view
        bottomView = UIView(frame: CGRect(x: 0, y: 548, width: 375, height: 80))
        bottomView?.backgroundColor = UIColor(red: 65/255, green: 105/255, blue: 225/255, alpha: 0.9)
        bottomView?.layer.cornerRadius = 10.0
        
        // location name label
        bottomLocationNameLabel = UILabel(frame: CGRect(x: 10, y: 5, width: 300, height: 30))
        bottomLocationNameLabel?.backgroundColor = UIColor.clear
        bottomLocationNameLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        bottomLocationNameLabel?.textColor = UIColor.white
        bottomLocationNameLabel?.text = "name"
        
        // location subtitle label
        bottomLocationSubtitleLabel = UILabel(frame: CGRect(x: 10, y: 35, width: 300, height: 30))
        bottomLocationSubtitleLabel?.backgroundColor = UIColor.clear
        bottomLocationSubtitleLabel?.font = UIFont.systemFont(ofSize: 14)
        bottomLocationSubtitleLabel?.textColor = UIColor.orange
        bottomLocationSubtitleLabel?.text = "subtitle"
        
        // image view
        bottomImageView = UIImageView(frame: CGRect(x: 305, y: 10, width: 50, height: 50))
        
        bottomView?.addSubview(bottomLocationNameLabel!)
        bottomView?.addSubview(bottomLocationSubtitleLabel!)
        bottomView?.addSubview(bottomImageView!)
        
        
        // add gesture
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.showPlaceDetail(_:)))
        bottomView?.addGestureRecognizer(gesture)
        
        self.view.addSubview(bottomView!)
        bottomView?.isHidden = true
    }
    
    // show place details
    func showPlaceDetail(_ sender:UITapGestureRecognizer){
        // do other task
        performSegue(withIdentifier: "showPlaceDetail", sender: self)
    }
    
    // show place details
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlaceDetail" {
            let vc = segue.destination as! PlaceDetailViewController
            vc.locationDetail = self.locationDetail
            vc.iconImage = self.bottomImageView?.image
        }
    }
    
    
    
    
    // get detail information of the selected location
    func getPlaceDetailResults() {
        let latitude = self.parseOptionalValue(degree: "\(self.selectedPin?.coordinate.latitude)")
        let longitute = self.parseOptionalValue(degree: "\(self.selectedPin?.coordinate.longitude)")
        var name = self.parseOptionalValue(degree: "\(self.selectedPin?.name)")
        name = name.replacingOccurrences(of: "\"", with: "")
        name = name.replacingOccurrences(of: " ", with: "+")
        SharedNetworking.networkInstance.googlePlaceSearchResults(latitute: latitude, longitute: longitute, name: name) { (result, success) -> Void in
            if success == true {
                DispatchQueue.main.async {
                    self.bottomView?.isHidden = false
                    self.locationDetail = result
                    guard let name = result["name"] as? String,
                        let address = result["formatted_address"] as? String else  { return}
                    self.bottomLocationNameLabel?.text = name
                    self.bottomLocationSubtitleLabel?.text = address
                    
                    // icon
                    guard let iconUrl = result["icon"] as? String else {   return}
                    
                    SharedNetworking.networkInstance.downloadImage(urlString: iconUrl){
                        (imageData, success) -> Void in
                        if success {
                            print(2)
                            DispatchQueue.main.async {
                                let iconImage = UIImage(data: imageData as Data)
                                self.bottomImageView!.image = iconImage
                            }
                        }
                    }
                }
            }
            else{
                print("false")
                DispatchQueue.main.async {
                    self.bottomView?.isHidden = true
                }
            }
            
            
        }
        
    }
    
    // convert the coordinate degree into string
    func parseOptionalValue(degree: String) -> String {
        var result = degree
        print("degree:\(degree)")
        let start = result.index(result.startIndex, offsetBy: 9)
        let end = result.index(result.endIndex, offsetBy: -1)
        let range = start..<end
        result = result.substring(with: range)
        print(result)
        return result
    }
    
}

// CLLocationManager Delegate
extension MapViewController : CLLocationManagerDelegate {
    // when user respond to the permission dialogue
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            self.locationManager.requestLocation()
            
        }
    }
    
    // when location information comes back
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            whiteView.removeFromSuperview()
            locationSearchController?.searchBar.isUserInteractionEnabled = true
            
            print("location: \(location)")
            currentLocation = location
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            DispatchQueue.main.async {
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
    
    // print out the error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
}


// protocol used to make the mapView zoom in a new location according the location search results
extension MapViewController: MapSearchProtocol {
    func dropPinZoomIn(placemark: MKPlacemark){
       
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        
        // update the map
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        
        // get detail information from yelp
        self.getPlaceDetailResults()
    }
}


// customize the mapview
extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "go"), for: .normal)
        button.addTarget(self, action: #selector(self.showDirectionView), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
    
    func showDirectionView() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "DirectionViewController") as! DirectionViewController
        vc.scheduleSetLocationProtocolDelegate = self.scheduleSetLocationProtocolDelegate
        vc.sourceCoordinate = self.currentLocation?.coordinate
        vc.destCoordinate = self.selectedPin?.coordinate
        vc.searchRegion = mapView.region
        vc.fromScheduleVC = self.fromScheduleVC
        present(vc, animated: true, completion: nil)
        vc.sourceLabel.text = "My Location"
        vc.destLabel.text = selectedPin?.name
    }
    
}








