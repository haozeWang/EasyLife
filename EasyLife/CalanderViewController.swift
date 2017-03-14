//
//  CalanderViewController.swift
//  EasyLife
//
//  Created by 王昊泽 on 17/3/8.
//  Copyright © 2017年 Haoze Wang. All rights reserved.
//

import UIKit
import UserNotifications
import MapKit

private let reuseIdentifier = "Cell"

class CalanderViewController: UIViewController,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var CollectionView: UICollectionView!
    
    @IBOutlet weak var instructionButton: UIBarButtonItem!
    
    var date:Date!
    var weekArray:[String] = []
    var rec_month = getstringfromdate_M(date: Date())
    
    let locationManager = CLLocationManager()
    
    // instruction view
    var instructionView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        date = Date()
    
        weekArray = ["M","T","W","T","F","S","S"]
        CollectionView.delegate = self
        CollectionView.dataSource = self
    
        CollectionView.backgroundColor = UIColor.white
 
        self.showLabelString(date)
        self.setCollectionViewLayout()
        
        
        // ask for notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {allowed, error in
            if !allowed {
                print("Not Allowed!")
            }
        })
        
        // ask for location permission
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        self.initInstructionView()
    }
    
    
    func initInstructionView() {
        
        // initialize the introduction view
        instructionView = UIView(frame: CGRect(x: 0, y: 0,
                                         width: self.view.frame.width,
                                         height: self.view.frame.height))
        instructionView.backgroundColor = UIColor.init(white: 1, alpha: 0.9)
        
        let introTitle = UILabel(frame: CGRect(x: 100, y: 70, width: 175, height: 40))
        introTitle.text = "Instructions"
        introTitle.backgroundColor = UIColor.orange
        introTitle.textColor = UIColor.white
        introTitle.textAlignment = .center
        introTitle.font = UIFont.boldSystemFont(ofSize: 28)
        introTitle.layer.cornerRadius = 8
        introTitle.layer.masksToBounds = true
        instructionView.addSubview(introTitle)
        
        // initialize the introduction text
        let introText = UILabel(frame: CGRect(x: 20, y: 115, width: 335, height: 400))
        introText.text = "You can use this app to schedule your events. When schedule events, you can choose to either use a map or not. After you made you schedule, you can select a date on the calendar and find your schedules at that day.\n\n You can use the map to select your destination and choose the route you would like to go on to reach the destination. \n\n Taping on a schedule cell shows you more about the schedule, including the weather, the starting point and the destination. \n\n Notifications will be sent to you at the reminder time."
        introText.numberOfLines = 0
        introText.font = UIFont(name: (introText.font?.fontName)!, size: 17)
        introText.textAlignment = NSTextAlignment.center
        introText.backgroundColor = UIColor.clear
        instructionView.addSubview(introText)
        
    
        // add a button to dismiss the introduction
        let introEndButton = UIButton(frame: CGRect(x: 125, y: 530, width: 125, height: 50))
        introEndButton.backgroundColor = UIColor.init(red: 0, green: 100/255, blue: 200/255, alpha: 1)
        introEndButton.setTitle("Return", for: .normal)
        introEndButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 24)
        introEndButton.setTitleColor(UIColor.white, for: .normal)
        introEndButton.addTarget(self, action: #selector(closeInstruction), for: .touchUpInside)
        instructionView.addSubview(introEndButton)

    }
    
    
    @IBAction func openInstruction(_ sender: Any) {
        print("open instructions")
        view.addSubview(self.instructionView)
        instructionView.center.y = self.view.center.y*(-1)
        UIView.animate(withDuration: 1.0,
                       animations: {
                        self.instructionView.center.y = self.view.center.y
        },
                       completion: nil)
        self.instructionButton.isEnabled = false
        
    }
    
    
    // close the instructions
    func closeInstruction() {
        print("close instructions")
        UIView.animate(withDuration: 1.0,
                       animations: {
                        self.instructionView.center.y = self.view.center.y*3
        },
                       completion: {
                        (value:Bool)->Void in
                        self.instructionView.removeFromSuperview()
                        self.instructionButton.isEnabled = true
        })
        
    }
    
    
    
    
    
    
    
    func setCollectionViewLayout(){
        
    
        let width:CGFloat = UIScreen.main.bounds.size.width
        let layOut:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layOut.itemSize = CGSize(width: width / 7, height: width / 9)
        layOut.minimumLineSpacing = 0.0
        layOut.minimumInteritemSpacing = 0.0
        CollectionView.setCollectionViewLayout(layOut, animated: true)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return weekArray.count
        }else{
            
            return 42
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickNextBtn(_ sender: Any) {
        var dateComponents:DateComponents = DateComponents.init()
        dateComponents.month = 1;
        
        let newDate:Date = (Calendar.current as NSCalendar).date(byAdding: dateComponents, to: date, options: .matchStrictly)!
        
        
        self.showLabelString(newDate)
  
        date = newDate;
        CollectionView.reloadData()
        
    }
    
    
    
    @IBAction func clickPreBtn(_ sender: Any) {
        
        var dateComponents:DateComponents = DateComponents.init()
        dateComponents.month = -1;
        
        let newDate:Date = (Calendar.current as NSCalendar).date(byAdding: dateComponents, to: date, options: .matchStrictly)!
        
        self.showLabelString(newDate)
        
        date = newDate;
        CollectionView .reloadData()
        
    }
    
    func showLabelString(_ date:Date){
        var month: String!
        if((currentMonth(date) == 1)) {
            month = "Jan"
            rec_month = "01"
        }
        else if((currentMonth(date) == 2)) {
            month = "Feb"
            rec_month = "02"
        }
        else if((currentMonth(date) == 3)) {
            month = "Mar"
            rec_month = "03"
        }
        else if((currentMonth(date) == 4)) {
            month = "Apr"
            rec_month = "04"
        }
        else if((currentMonth(date) == 5)) {
            month = "May"
            rec_month = "05"
        }
        else if((currentMonth(date) == 6)) {
            month = "Jun"
            rec_month = "06"
        }
        else if((currentMonth(date) == 7)) {
            month = "Jul"
            rec_month = "07"
        }
        else if((currentMonth(date) == 8)) {
            month = "Aug"
            rec_month = "08"
        }
        else if((currentMonth(date) == 9)) {
            month = "Sep"
            rec_month = "09"
        }
        else if((currentMonth(date) == 10)) {
            month = "Oct"
            rec_month = "10"
        }
        else if((currentMonth(date) == 11)) {
            month = "Nov"
            rec_month = "11"
        }
        else if((currentMonth(date) == 12)) {
            month = "Dec"
            rec_month = "12"
        }
        
        
        showLabel.text = "\(month as String)  \(self.currentYear(date))"
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CalenderCell
       
        if indexPath.section == 0 {
            cell.timerLabel.text = weekArray[indexPath.row]
            cell.timerLabel.textColor = UIColor ( red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5 )
        }else{
            
            cell.timerLabel.textColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5 )
            var allDayArray:[String] = []
        
            let day:Int = self.currentFirstDay(date)
            var OneI = 0
            while OneI < day {
                allDayArray.append("")
                OneI += 1
            }
     
            OneI = 1
            let days = self.currentMonthOfDays(date)
            while OneI < days {
                allDayArray.append(String(OneI))
                OneI += 1
            }
            
     
            OneI = allDayArray.count
            while OneI < 42 {
                allDayArray.append("")
                OneI += 1
            }
           
            cell.timerLabel.text = allDayArray[indexPath.row]
            
        }
        
        return cell
    }
    
    func currentYear(_ date:Date)->Int{
        
        let componentsYear:DateComponents = (Calendar.current as NSCalendar).components([.year,.month,.day], from: date)
        
        return componentsYear.year!
    }
    
    
    func currentMonth(_ date:Date)->Int{
        
        let componentsYear:DateComponents = (Calendar.current as NSCalendar).components([.year,.month,.day], from: date)
        
        return componentsYear.month!
    }
    

   
    /**
     *  get the number of day in one month
     */
    func currentDay(_ date:Date)->Int{
        
        let componentsYear:DateComponents = (Calendar.current as NSCalendar).components([.year,.month,.day], from: date)
        
        return componentsYear.day!
    }
   
    func currentMonthOfDays(_ date:Date)->Int{
        
        let totalDaysInMonth:NSRange = (Calendar.current as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: date)
        return totalDaysInMonth.length
        
    }
    /**
     *  the first day of the month
     */
    func currentFirstDay(_ date:Date)->Int{
        
        var calender:Calendar = Calendar.current
        calender.firstWeekday = 2
        
        
        var comp:DateComponents = (calender as NSCalendar).components([.year,.month,.day], from: date)
        comp.day = 1
        
        let  firstDayOfMonthDate = calender.date(from: comp)
        let firstWeekDay = (calender as NSCalendar).ordinality(of: NSCalendar.Unit.weekday, in: NSCalendar.Unit.weekOfMonth, for: firstDayOfMonthDate!)
        
        return firstWeekDay - 1
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "senddate"{
            let des = segue.destination as! EveryDaySchedule
            let cell = sender as! CalenderCell
            _ = self.CollectionView.indexPath(for: cell)
            let a = showLabel.text
            let last2 = a?.substring(from:(a?.index((a?.endIndex)!, offsetBy: -2))!)
            var day = cell.timerLabel.text! as String
            if(day.characters.count == 1){
                day = "0\(day)"
            }
            let date = "\(rec_month)/\(day as String)/\(last2! as String)"
            print(date)
            des.date = date
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

func getstringfromdate_M(date : Date) -> String{
    let dateformatter = DateFormatter()
    
    dateformatter.dateFormat = "MM"
    
    let now = dateformatter.string(from: date)
    return now
    
}

