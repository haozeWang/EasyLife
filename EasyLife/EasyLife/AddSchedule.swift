//
//  AddSchedule.swift
//  EasyLife
//
//  Created by 王昊泽 on 17/3/10.
//  Copyright © 2017年 Haoze Wang. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
class AddSchedule: UIViewController,UITextViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate{
    
    
    @IBOutlet weak var RouteWay: UILabel!
    @IBOutlet weak var exp_timeLabel: UILabel!
    @IBOutlet weak var end_point: UILabel!
    @IBOutlet weak var begin_point: UILabel!
    @IBOutlet weak var SetRemTime: UIButton!
    @IBOutlet weak var RemMinute: UILabel!
    @IBOutlet weak var Remhours: UILabel!
    @IBOutlet weak var RemMonth: UILabel!
    @IBOutlet weak var hours: UILabel!
    @IBOutlet weak var UITextLabel: UITextField!
    @IBOutlet weak var UIPickerView: UIView!
    @IBOutlet weak var SetTime: UIButton!
    @IBOutlet weak var Minute: UILabel!
    @IBOutlet weak var Month: UILabel!
    @IBOutlet weak var YearPickerView: UIPickerView!
    @IBOutlet weak var ScheduleLabel: UILabel!
   
    @IBOutlet weak var show_hour: UILabel!
    @IBOutlet weak var show_minute: UILabel!
    @IBOutlet weak var TextField: UITextView!
    var set_fin_time = false
   // var update: UpdateViewProtocol? = nil
    var updateDelegate: UpdateViewProtocol? = nil
    // information about source and destination
    var sourceLatitude = "0.0"
    var sourceLongitude = "0.0"
    var destLatitude = "0.0"
    var destLongitude = "0.0"
    var sourceName = "source"
    var destName = "destination"
    var expectedTime = 0
    var point_begin = ""
    var point_end = ""
    var dummy_expectedtime = false
    var initSource: String? = nil
    var initDest: String? = nil
    
    var expTimeString = "0"
    var travelMode = "driving"
    
    var flag = 1
    var changeflag = 1
    var day : [String] = []
    var date : [Date] = []
    var record_date_begin : Date!
    var record_date_end : Date!
    var hour: [String] = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23"]
    var minutes: [String] = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60"]
    override func viewDidLoad() {
        super.viewDidLoad()
      
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Schedule.jpeg")
        self.view.insertSubview(backgroundImage, at: 0)
        TextField.delegate = self
        YearPickerView.delegate = self
        YearPickerView.dataSource = self
        UITextLabel.delegate = self
        TextField.text = "Please enter the description of the schedule"
        TextField.textColor = UIColor.lightGray
        SetTime.tintColor = UIColor.black
        Month.text = "Today"
        hours.text = "00:"
        Minute.text = "00"
        show_hour.text = "00:"
        show_minute.text = "00"
        Remhours.text = "00:"
        RemMinute.text = "00"
        record_date_begin = Date()
        record_date_end = Date()
        setTextField()
        creatday()
        let myGesture = UITapGestureRecognizer(target: self, action:#selector(self.tappedAwayFunction(sender:)) )
        self.view.addGestureRecognizer(myGesture)
        // Do any additional setup after loading the view.
        
        if initSource != nil {
            self.begin_point.text = initSource
        }
        if initDest != nil {
            self.end_point.text = initDest
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(!ReachAbility.isInternetAvailable()){
            print("this it test")
            let alert = UIAlertController(title: "Error",message:"Please connect to the Internet", preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok,I know", style: .default, handler: {
                action in
                self.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func tappedAwayFunction(sender: UITapGestureRecognizer){
        TextField.resignFirstResponder()
        UITextLabel.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        TextField.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setTextField(){
        TextField.layer.backgroundColor = UIColor.white.cgColor
        TextField.layer.borderColor = UIColor.gray.cgColor
        TextField.layer.borderWidth = 0.0
        TextField.layer.cornerRadius = 5
        TextField.layer.masksToBounds = false
        TextField.layer.shadowRadius = 2.0
        TextField.layer.shadowColor = UIColor.black.cgColor
        TextField.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        TextField.layer.shadowOpacity = 1.0
        TextField.layer.shadowRadius = 1.0
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView.text == "Please enter the description of the schedule"){
            textView.text = ""
            TextField.textColor = UIColor.black
        }
        textView.becomeFirstResponder()
    }
    
   // func tappedAwayFunction
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
   
    func pickerView(_ pickerView: UIPickerView,numberOfRowsInComponent component: Int) -> Int{
        if component == 0
        {
            
            let count = self.day.count
            return count
        }
        else if component == 1
        {
            
            let count = self.hour.count
           return count
        }
        else if component == 2
        {
            
            let count = self.minutes.count
            return count
        }
        return 0
    }

    
    @IBAction func GiveupSchedule(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func dismissSchedule(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    
    
    @IBAction func SubmitSchedule(_ sender: Any) {
        if(UITextLabel.text == ""){
            let alert = UIAlertController(title: "Error",message:"Please set the title of this schedule", preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok,I know", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if(point_begin == "" || point_end == ""){
            let alert = UIAlertController(title: "Error",message:"Please set Location", preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok,I know", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
        let moc = DataController().managedObjectContext
        let temp = Task.init(entity: NSEntityDescription.entity(forEntityName: "Task", in:moc)!, insertInto: moc)
        temp.begin = begin_point.text
        temp.end = end_point.text
        temp.desc = TextField.text
        temp.title = UITextLabel.text
        let begin = "\(createstringfromdate(date: record_date_begin)) \(hours.text! as String)\(Minute.text! as String)"
        let end = "\(createstringfromdate(date: record_date_end)) \(Remhours.text! as String)\(RemMinute.text! as String)"
       
    
        temp.fin_time = getdatefromstring(string: begin) as NSDate?
        temp.ram_time = getdatefromstring(string: end) as NSDate?
        temp.date = getstringfromdate_yy(date: temp.fin_time as! Date)
        temp.id = "\(Date().timeIntervalSince1970)"
        temp.point_begin = point_begin
        temp.point_end = point_end
        temp.exp_time = Int64(expectedTime)
        var sche = schedule()
        sche =  sche.copy(task: temp)
        schedule.scheduleInstance.insertDate(schedule: temp)
        
        // set notifications
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: {(settings) in
            if settings.authorizationStatus == .authorized {
                let content = UNMutableNotificationContent()
                content.title = sche.title
                let description = String(sche.desc)!
                
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "MMM dd, EEE HH:mm"
                let displayTime = dateformatter.string(from: self.getdatefromstring(string: begin))
                content.body = "At \(displayTime), you have to arrive at \(description)!"
                content.sound = UNNotificationSound.default()
                let remindDate = self.getdatefromstring(string: end)
                let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: remindDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                            repeats: false)
                let identifier = String(sche.id)
                let request = UNNotificationRequest(identifier: identifier!,
                                                    content: content, trigger: trigger)
                center.add(request, withCompletionHandler: { (error) in
                    if let error = error {
                        // Something went wrong
                        print(error)
                    }
                })
                
            } else {
                // if not allowed
                print("Notification Not Allowed!")
            }
        })
        
        updateDelegate?.updatedayschedule()
        self.dismiss(animated: true, completion: nil);
    }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if 0 == component
        {
            
            let dictProvince = self.day[row]
            return dictProvince
        }
        else if 1 == component
        {
            
          return self.hour[row]
            
        }
        else if 2 == component
        {
            
           return self.minutes[row]
        }
        
        return nil
    }
    
    
    
    @IBAction func setRamtime(_ sender: Any) {
        changeflag = 2
        if(flag == 1){
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.view.bringSubview(toFront: self.UIPickerView)
                self.UIPickerView.center.y = 400
                self.dummy_expectedtime = true
                self.expectedTime = 0
            }, completion:{finish in
                
            })
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if 0 == component
        {
            if(changeflag == 1){
                Month.text = self.day[row]
                record_date_begin = self.date[row]}
            else{
                self.RemMonth.text = self.day[row]
                self.record_date_end = self.date[row]
            }
        }
        else if 1 == component
        {
            if(changeflag == 1){
                hours.text = "\(self.hour[row]as String):"
             show_hour.text = "\(self.hour[row]as String):" }
            else{
                Remhours.text = "\(self.hour[row]as String):"
                show_hour.text = "\(self.hour[row]as String):"
            }
            
        }
        else if 2 == component
        {
            if(changeflag == 1){
                Minute.text = self.minutes[row]
             show_minute.text = self.minutes[row]
            }
            else{
                RemMinute.text = self.minutes[row]
                 show_minute.text = self.minutes[row]
            }
            
        }

        
    }
    
    @IBAction func Finish(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.UIPickerView.center.y = 1000
        }, completion: {finish in
            if(self.dummy_expectedtime == false){
             let temp = "\(self.createstringfromdate(date: self.record_date_begin)) \(self.hours.text! as String)\(self.Minute.text! as String)"
            var time = Int(self.getdatefromstring(string: temp).timeIntervalSince1970)
            time = time - self.expectedTime
            
            let date = NSDate(timeIntervalSince1970: TimeInterval(time))
            self.record_date_end = date as Date!
            self.RemMonth.text = self.getstringfromdate(date: date as Date)
            self.Remhours.text = "\(self.getstringfromdate_hour(date: date as Date)):"
            self.RemMinute.text = self.getstringfromdate_minute(date: date as Date)
            }
            else{
                self.dummy_expectedtime = false
            }
        })
    }
    
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat{
        return CGFloat(127)
    }
    
    
    @IBAction func SetTime(_ sender: Any) {
        set_fin_time = true
        changeflag = 1
        if(flag == 1){
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.view.bringSubview(toFront: self.UIPickerView)
                self.UIPickerView.center.y = 400
            }, completion:{finish in
              
                
            })
        }
    }
    
    
    
    func creatday(){
         date.append(Date())
        day.append("Today")
        for i in 1 ... 90{
            day.append(getstringfromdate(date: getnextdate(day: i)))
        }
    }
    
    
    func getnextdate(day : Int)-> Date{
        let calendar = Calendar.current
        let twoDaysAgo = calendar.date(byAdding: .day, value: day , to: Date())
        date.append(twoDaysAgo!)
        return twoDaysAgo!
    }
    
    
    func getstringfromdate(date : Date) -> String{
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "MM/dd/EEE"
        
        let now = dateformatter.string(from: date)
        return now

    }
    
    
    func getdatefromstring(string: String)->Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yy/MM/dd/EEE HH:mm"
        return formatter.date(from: string)!
    }

   
    
    func createstringfromdate(date : Date)->String{
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "yy/MM/dd/EEE"
        
        let now = dateformatter.string(from: date)
        return now
    }
    
    func getstringfromdate_yy(date: Date) -> String{
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "MM/dd/yy"
        
        let now = dateformatter.string(from: date)
        return now
    }
    
    
    func getstringfromdate_hour(date: Date) -> String{
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "HH"
        
        let now = dateformatter.string(from: date)
        return now
    }
    
    func getstringfromdate_minute(date: Date) -> String{
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "mm"
        
        let now = dateformatter.string(from: date)
        return now
    }

    
    
    
    @IBAction func setLocation(_ sender: Any) {
        if(set_fin_time == false){
            let alert = UIAlertController(title: "Error",message:"Please choose the finishing time", preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok,I know", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
       else  {
        let navigationVC = self.storyboard?.instantiateViewController(withIdentifier: "mapNavigationVC") as! UINavigationController
        let vc = navigationVC.viewControllers.first as! MapViewController
        vc.scheduleSetLocationProtocolDelegate = self
        vc.fromScheduleVC = true
        present(navigationVC, animated: true, completion: nil)
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



extension AddSchedule: ScheduleSetLocationProtocol {
    func updateLocation(sourceLat: String, sourceLon: String, destLat: String, destLon: String, sourceName: String, destName: String, expectedTime: Int, expTimeString: String, travelMode: String) {
        self.sourceLatitude = sourceLat
        self.sourceLongitude = sourceLon
        self.destLatitude = destLat
        self.destLongitude = destLon
        self.sourceName = sourceName
        self.destName = destName
        self.expectedTime = expectedTime
        self.begin_point.text = sourceName
        self.end_point.text = destName
        
        // expected time string
        self.expTimeString = expTimeString
        self.travelMode = travelMode
        exp_timeLabel.text = "EXP TIME:\(expTimeString)"
        RouteWay.text = travelMode
        let begin = "\(createstringfromdate(date: record_date_begin)) \(hours.text! as String)\(Minute.text! as String)"
        var time = Int(getdatefromstring(string: begin).timeIntervalSince1970)
        time = time - expectedTime
        let date = NSDate(timeIntervalSince1970: TimeInterval(time))
        record_date_end = date as Date!
        RemMonth.text = getstringfromdate(date: date as Date)
        Remhours.text = "\(getstringfromdate_hour(date: date as Date)):"
        RemMinute.text = getstringfromdate_minute(date: date as Date)
        point_begin = "lat=\(sourceLatitude)&lon=\(sourceLongitude)"
        point_end = "lat=\(destLatitude)&lon=\(destLongitude)"
    }
}
