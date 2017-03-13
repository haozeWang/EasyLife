//
//  LocationSearchProtocol.swift
//  EasyLife
//
//  Created by Meng Wang on 3/11/17.
//  Copyright © 2017 Haoze Wang. All rights reserved.
//

import MapKit

/// - Description: This protocol is used to update the source and destination of the direction route when selecting a new one
protocol LocationSearchProtocol {
    func updateDirection(placemark: MKPlacemark, locationType: String)
}
