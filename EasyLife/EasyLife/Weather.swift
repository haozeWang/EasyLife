//
//  Weather.swift
//  EasyLife
//
//  Created by 王昊泽 on 17/3/8.
//  Copyright © 2017年 Haoze Wang. All rights reserved.
//

import UIKit

class Weather: NSObject {
    var city : String!
    var country :String!
    var weather : String!
    var temperature: Int!
    var image : String!
    var time : String!
    var dt: Int!
     init(city: String, country: String, weather: String, temperature: Int, image:String) {
        self.city = city
        self.country = country
        self.weather = weather
        self.temperature = temperature
        self.image = image
    }
    
}
