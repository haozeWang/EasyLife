//
//  MyRoute.swift
//  EasyLife
//
//  Created by Meng Wang on 3/11/17.
//  Copyright © 2017 Haoze Wang. All rights reserved.
//

import Foundation

// class of my custom route
class MyRoute {
    var time = 0    // in seconds
    var timeText = ""       // readable time text
    var distance = 0        // in meters
    var distanceText = ""   // in miles
    
    init(){}
    
    init(time: Int, timeText: String, distance: Int, distanceText: String) {
        self.time = time
        self.timeText = timeText
        self.distance = distance
        self.distanceText = distanceText
    }
}
