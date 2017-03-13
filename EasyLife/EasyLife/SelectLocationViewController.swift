//
//  SelectLocationViewController.swift
//  EasyLife
//
//  Created by Meng Wang on 3/10/17.
//  Copyright © 2017 Haoze Wang. All rights reserved.
//

import UIKit
import MapKit

class SelectLocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    // search results
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    
    // source or destination
    var type = "source"
    
    // region for search
    var searchRegion: MKCoordinateRegion? = nil
    
    var locationSearchDelegate: LocationSearchProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.topItem?.title = type
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        cancelButton.action = #selector(cancel)
    }
    
    
    func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    // set the table cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "LocationCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }

    
    // set row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        print(selectedItem.coordinate)
        locationSearchDelegate?.updateDirection(placemark: selectedItem, locationType: type)
        dismiss(animated: true, completion: nil)
    }
    
    
    // parse the location address
    func parseAddress(selectedItem: MKPlacemark) -> String {
        // put a space between street number and street name
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between city and state
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    // when search text change, do search
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // unwrap the optional value
        guard let region = self.searchRegion,
            let searchBarText = searchBar.text else {
                return
        }
        
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = region
        let search = MKLocalSearch(request: request)
        
        // start search
        search.start { response, _ in
            // if no response then return
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            
            print(self.matchingItems.count)
            
            // table view reload data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

    }
    
    
    
    // when search button clicked, do search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // unwrap the optional value
        guard let region = self.searchRegion,
            let searchBarText = searchBar.text else {
                return
        }
        
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = region
        let search = MKLocalSearch(request: request)
        
        // start search
        search.start { response, _ in
            // if no response then return
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            
            print(self.matchingItems.count)
            
            // table view reload data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

    }
}

