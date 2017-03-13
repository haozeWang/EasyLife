//
//  Task+CoreDataProperties.swift
//  EasyLife
//
//  Created by 王昊泽 on 17/3/13.
//  Copyright © 2017年 Haoze Wang. All rights reserved.
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task");
    }

    @NSManaged public var begin: String?
    @NSManaged public var date: String?
    @NSManaged public var desc: String?
    @NSManaged public var end: String?
    @NSManaged public var exp_time: Int64
    @NSManaged public var fin_time: NSDate?
    @NSManaged public var id: String?
    @NSManaged public var point_begin: String?
    @NSManaged public var point_end: String?
    @NSManaged public var ram_time: NSDate?
    @NSManaged public var title: String?

}
