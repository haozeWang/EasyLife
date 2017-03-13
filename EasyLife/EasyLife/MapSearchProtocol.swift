//
//  MapSearchProtocol.swift
//  hello map
//
//  Created by Meng Wang on 3/9/17.
//  Copyright © 2017 Meng Wang. All rights reserved.
//

import MapKit

/// - Description: This protocol is used to make the mapView zoom in a new location according the location search results
protocol MapSearchProtocol {
    func dropPinZoomIn(placemark: MKPlacemark)
}
