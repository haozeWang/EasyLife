//
//  ScheduleSetLocation.swift
//  EasyLife
//
//  Created by Meng Wang on 3/12/17.
//  Copyright © 2017 Haoze Wang. All rights reserved.
//

import Foundation

protocol ScheduleSetLocationProtocol {
    func updateLocation(sourceLat: String, sourceLon: String, destLat: String, destLon: String, sourceName: String, destName: String, expectedTime: Int)
}
