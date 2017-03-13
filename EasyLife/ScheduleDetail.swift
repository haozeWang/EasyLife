//
//  ScheduleDetail.swift
//  EasyLife
//
//  Created by 王昊泽 on 17/3/8.
//  Copyright © 2017年 Haoze Wang. All rights reserved.
//

import UIKit

class ScheduleDetail: UIViewController {

    @IBOutlet weak var weather_end: UILabel!
    @IBOutlet weak var weather_begin: UILabel!
    
    @IBOutlet weak var information: UILabel!
    @IBOutlet weak var image_end: UIImageView!
    @IBOutlet weak var image_begin: UIImageView!
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var ram_time: UILabel!
    @IBOutlet weak var begin_time: UILabel!
    
    @IBOutlet weak var endcityname: UIButton!
    @IBOutlet weak var begincityname: UIButton!
    @IBOutlet weak var name: UILabel!
    var location_begin = "chicago"
    var location_end = "chicago"
    var point_begin = "lat=41.881832&lon=-87.623177"
    var point_end = "lat=41.881832&lon=-87.623177"
    var task : schedule!
    var date_begin: Weather!
    var date_end: Weather!
    var url:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "003.jpg")
        self.view.insertSubview(backgroundImage, at: 0)
        self.name.text = task.title
        self.desc.text = task.desc
       // button.setTitle("Button Title",for: .normal)
        self.begincityname.setTitle(task.begin, for: .normal)
        self.endcityname.setTitle(task.end, for: .normal)
        self.begin_time.text = getstringfromdate_schedule(date: task.fin_time as Date)
        self.ram_time.text = getstringfromdate_schedule(date: task.ram_time as Date)
        
        loadcurrdate(flag: 1)
        loadcurrdate(flag: 2)
        let date = NSDate()
        loadfurdata(date:date )
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadcurrdate(flag : Int){
        
        var url: String!
        if(flag == 1){
            url = "http://api.openweathermap.org/data/2.5/weather?\(point_begin)&appid=e5ad7ed727b66d69dc3c323ad8b8fd71"
        }
        if(flag == 2){
            url = "http://api.openweathermap.org/data/2.5/weather?\(point_end)&appid=e5ad7ed727b66d69dc3c323ad8b8fd71"
        }
        
        SharedNetwork.SharedInstance.grabSomeData(url){(response) -> Void in
            print(url)
            DispatchQueue.main.async
                {
                    if let responsedate = response as? [String:AnyObject]
                        
                    {
                        
                        let weather = responsedate["weather"] as! [AnyObject]
                        
                        let weather_clear = weather[0] as AnyObject
                        let weather_date = weather_clear["description"] as! String
                        let main = responsedate["main"] as! [String:AnyObject]
                        let temperature = main["temp"] as! Int
                        let code = weather_clear["icon"] as! String
                        let sys = responsedate["sys"] as! [String:AnyObject]
                        let country = sys["country"] as! String
                        let city = responsedate["name"] as! String
                        if(flag == 1){
                            self.date_begin = Weather(city: city, country: country, weather: weather_date, temperature: temperature, image: code)
                            self.weather_begin.text = self.date_begin.weather
                            self.image_begin.image = self.getimage(url: "http://openweathermap.org/img/w/\(code).png")
                        }
                        else{
                            self.date_end = Weather(city: city, country: country, weather: weather_date, temperature: temperature, image: code)
                            self.weather_end.text = self.date_end.weather
                            self.image_end.image = self.getimage(url: "http://openweathermap.org/img/w/\(code).png")
                            
                        }
                    }
                    
                    
            }
        }
    }
    
    func loadfurdata(date: NSDate){
        var time = Int(date.timeIntervalSince1970)
        time = time - 21800
        print(time)
        url = "http://api.openweathermap.org/data/2.5/forecast?\(point_end)&appid=e5ad7ed727b66d69dc3c323ad8b8fd71"
        print(url)
        SharedNetwork.SharedInstance.grabSomeData(url){(response) -> Void in
            
            DispatchQueue.main.async
                {
                    if let responsedate = response?["list"] as? [AnyObject]
                    {
                        for i in responsedate{
                            if i["dt"] as! Int > time {
                                let wea = i["weather"] as! [AnyObject]
                                let weather_clear = wea[0] as AnyObject
                                let weather_date = weather_clear["description"] as! String
                                if weather_date == "snow"{
                                self.information.text = "During your trip phase，would be snowing. Be careful"
                                return

                                }
                                else if weather_date == "rain" {
                                self.information.text = "During your trip phase，would be raining. Be careful"
                                return
                                }
                                else if weather_date == "thunderstorm"{
                                self.information.text = "During your trip phase，would have thunderstorm. Be careful"
                                    return
                                }
                                else if weather_date == "shower rain" {
                                self.information.text = "During your trip phase，would have shower rain. Be careful"
                                return
                                }
                            }
                            else {
                                self.information.text = "Nice weather. Enjoying your trip"
                            }
                        }
                        self.information.text = "Nice weather. Enjoying your trip"

                    }
            }

        }
    }
    
    
    func getimage(url:String)->UIImage{
        let path = URL(string: url)
        let data = try? Data(contentsOf: path!)
        return UIImage(data: data!)!
    }
    
    func getstringfromdate_schedule(date : Date) -> String{
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "MM/dd/EEE HH:mm"
        
        let now = dateformatter.string(from: date)
        return now
        
    }
     

   
    @IBAction func getbeginweather(_ sender: Any) {
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "weatherforecast") as! weatherforecast
        myVC.location_end = point_begin
        navigationController?.pushViewController(myVC, animated: true)
        
    }
  
    @IBAction func getendweather(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "weatherforecast") as! weatherforecast
        myVC.location_end = point_end
        navigationController?.pushViewController(myVC, animated: true)
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
