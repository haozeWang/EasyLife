//
//  EveryDaySchedule.swift
//  EasyLife
//
//  Created by 王昊泽 on 17/3/11.
//  Copyright © 2017年 Haoze Wang. All rights reserved.
//

import UIKit
import CoreData
import  UserNotifications
class EveryDaySchedule: UITableViewController,UIActionSheetDelegate, UpdateViewProtocol {
    
    var task: [schedule]!
    var date : String!
    override func viewDidLoad() {
        
        super.viewDidLoad()
       // schedule.scheduleInstance.removeDate(id: "")
        if(date == nil){
            let currdate = getstringfromdate(date: Date())
            task =  schedule.scheduleInstance.fetchDate(date: currdate)
        }
        else{
            task =  schedule.scheduleInstance.fetchDate(date: date)
        }
        print(task.count)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return task.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Daytablecell", for: indexPath) as! EveryDayScheduleCell
            let issue = task[indexPath.row]
            cell.title.text = issue.title
            cell.fin_time.text = createstringfromdate(date: issue.fin_time as Date)
            return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(task[0].title)
        if segue.identifier == "showweather"
        {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = task[0]
                
                let controller = segue.destination as! ScheduleDetail
                controller.point_begin = object.point_begin
                controller.point_begin = object.point_end
                controller.location_begin = object.begin
                controller.location_end = object.end
                print(object.title)
                controller.task = object
            }
        }
    }
    /*
    func updatadayschedule(){
        tableView.reloadData()
    }
 
   */
    @IBAction func AddSchedule(_ sender: Any) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Please select", message: "Option to select", preferredStyle: .actionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton: UIAlertAction = UIAlertAction(title: "Use Map", style: .default)
        { void in
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HaveMap") as! AddSchedule
            viewController.updateDelegate = self
            self.present(viewController, animated: true, completion: nil)

        }
        
        actionSheetController.addAction(saveActionButton)
        
        let deleteActionButton: UIAlertAction = UIAlertAction(title: "Do not use map", style: .default)
        { void in
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddTask") as! AddTask
            viewController.updateDelegate = self
            self.present(viewController, animated: true, completion: nil)
        }
        actionSheetController.addAction(deleteActionButton)
        self.present(actionSheetController, animated: true, completion: nil)

    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
           let sch = task[indexPath.row]
            
            // delete the notification
            let identifier = sch.id
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            
            
            
           sch.removeDate(id: sch.id)
         // tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            if(date == nil){
                let currdate = getstringfromdate(date: Date())
                task =  schedule.scheduleInstance.fetchDate(date: currdate)
            }
            else{
                task =  schedule.scheduleInstance.fetchDate(date: date)
            }
           tableView.reloadData()
        }
    }
    
    func updatedayschedule(){
        if(date == nil){
            let currdate = getstringfromdate(date: Date())
            task =  schedule.scheduleInstance.fetchDate(date: currdate)
        }
        else{
            task =  schedule.scheduleInstance.fetchDate(date: date)
        }
        tableView.reloadData()
    }

    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

func getstringfromdate(date : Date) -> String{
    let dateformatter = DateFormatter()
    
    dateformatter.dateFormat = "MM/dd/yy"
    
    let now = dateformatter.string(from: date)
    return now
    
}

func createstringfromdate(date : Date)->String{
    let dateformatter = DateFormatter()
    
    dateformatter.dateFormat = "MM/dd/EEE HH:mm"
    
    let now = dateformatter.string(from: date)
    return now
}



