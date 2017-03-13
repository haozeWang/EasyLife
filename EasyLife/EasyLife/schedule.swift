//
//  schedule.swift
//  EasyLife
//
//  Created by 王昊泽 on 17/3/11.
//  Copyright © 2017年 Haoze Wang. All rights reserved.
//

import UIKit
import CoreData
class schedule: NSObject {
    var date = ""
    var title = ""
    var begin = ""
    var desc = ""
    var fin_time = NSDate()
    var ram_time = NSDate()
    var point_begin = ""
    var point_end = ""
    var id = ""
    var end = ""
    var exp_time = 0
    static let scheduleInstance = schedule()
    
     func insertDate(schedule : Task){
        let moc = DataController().managedObjectContext
        
        // we set up our entity by selecting the entity and context that we're targeting
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Task", into: moc) as! Task
        

        // add our data
        entity.setValue(schedule.date, forKey: "date")
        entity.setValue(schedule.title, forKey: "title")
        entity.setValue(schedule.begin, forKey: "begin")
        entity.setValue(schedule.desc, forKey: "desc")
        entity.setValue(schedule.end, forKey: "end")
        entity.setValue(schedule.fin_time, forKey: "fin_time")
        entity.setValue(schedule.ram_time, forKey: "ram_time")
        entity.setValue(schedule.point_begin, forKey: "point_begin")
        entity.setValue(schedule.point_end, forKey: "point_end")
        entity.setValue(schedule.id, forKey: "id")
        entity.setValue(schedule.exp_time, forKey: "exp_time")
        // we save our entity
        do {
            try moc.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    
    func fetchDate(date : String) -> [schedule]{
        let moc = DataController().managedObjectContext
        let TaskFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        let predicate = NSPredicate(format:"date == %@", date)
        print(date)
        TaskFetch.predicate = predicate
        
        do {
            var temp = [schedule]()
            let fetchedTask = try moc.fetch(TaskFetch) as! [Task]
            for i in fetchedTask{
                temp.append(copy(task: i))
            }
            return temp
            
        } catch {
            fatalError("Failed to fetch task: \(error)")
        }
    }
    
    
    func removeDate(id : String){
        let moc = DataController().managedObjectContext
        let TaskFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        let predicate = NSPredicate(format: "id == %@",id)
        TaskFetch.predicate = predicate
        
        do{
            let fetchTask = try moc.fetch(TaskFetch) as! [Task]
            for i in fetchTask{
                moc.delete(i)
            }
            
        }catch{
            fatalError("Failed to move task: \(error)")

        }
        do {
            try moc.save()
        } catch {
            fatalError("Failure to save task: \(error)")
        }

    }
    
    func copy(task : Task) -> schedule{
        let temp = schedule()
        if let i = task.date{
            temp.date = i
        }
        
        if let i = task.id{
            temp.id = i
        }
        temp.exp_time = Int(task.exp_time)
        if let i = task.desc{
            temp.desc = i
        }
        if let i = task.begin{
            temp.begin = i
        }
        if let i = task.end{
            temp.end = i
        }
        if let i = task.fin_time{
            temp.fin_time = i
        }
        if let i = task.ram_time{
            temp.ram_time = i
        }
        if let i = task.title{
            temp.title = i
        }
        if let i = task.date{
            temp.date = i
        }
        if let i = task.point_begin{
            temp.point_begin = i
        }
        if let i = task.point_end{
            temp.point_end = i
        }
        return temp
    }
    
}

func getstringfromdate_yy(date: Date) -> String{
    let dateformatter = DateFormatter()
    
    dateformatter.dateFormat = "MM/dd/yy"
    
    let now = dateformatter.string(from: date)
    return now
}
