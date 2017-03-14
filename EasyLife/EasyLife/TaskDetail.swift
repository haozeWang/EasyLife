//
//  TaskDetail.swift
//  EasyLife
//
//  Created by 王昊泽 on 17/3/13.
//  Copyright © 2017年 Haoze Wang. All rights reserved.
//

import UIKit
import SystemConfiguration
class TaskDetail: UIViewController {

    @IBOutlet weak var cityname: UILabel!
    @IBOutlet weak var moreweather: UIButton!
    @IBOutlet weak var WeatherImage: UIImageView!
    @IBOutlet weak var Nonetwork: UILabel!
    @IBOutlet weak var Rem_time: UILabel!
    @IBOutlet weak var Fin_time: UILabel!
    @IBOutlet weak var Desc: UILabel!
    @IBOutlet weak var name: UILabel!
    var task : schedule!
    var point_begin : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "schedule_bac1.jpg")
        self.view.insertSubview(backgroundImage, at: 0)
        if(!ReachAbility.isInternetAvailable()){
            moreweather.isHidden = true
            WeatherImage.isHidden = true
            cityname.isHidden = true
            Rem_time.text = getstringfromdate(date: task.ram_time as Date)
            Fin_time.text = getstringfromdate(date: task.fin_time as Date)
            Desc.text = task.desc
            name.text = task.title
            Nonetwork.isEnabled = true
            Nonetwork.text = "OOPS! Seems like something wrong with network"
        }
        else{
            moreweather.isEnabled = true
            cityname.isEnabled = true
            Nonetwork.isHidden = true
            point_begin = task.point_begin
            Nonetwork.isHidden = true
            Rem_time.text = getstringfromdate(date: task.ram_time as Date)
            Fin_time.text = getstringfromdate(date: task.fin_time as Date)
            Desc.text = task.desc
            name.text = task.title
            loadcurrdate()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadcurrdate(){
        
        var url: String!
           print(point_begin)
            url = "http://api.openweathermap.org/data/2.5/weather?\(point_begin as String)&appid=e5ad7ed727b66d69dc3c323ad8b8fd71"
        print(url)
        SharedNetwork.SharedInstance.grabSomeData(url){(response) -> Void in
            DispatchQueue.main.async
                {
                    if let responsedate = response as? [String:AnyObject]
                        
                    {
                        
                        let weather = responsedate["weather"] as! [AnyObject]
                        
                        let weather_clear = weather[0] as AnyObject
                        _ = weather_clear["description"] as! String
                        let main = responsedate["main"] as! [String:AnyObject]
                        _ = main["temp"] as! Int
                        let code = weather_clear["icon"] as! String
                        let city = responsedate["name"] as! String
                        self.WeatherImage.image = self.getimage(url: "http://openweathermap.org/img/w/\(code).png")
                         self.cityname.text = city

                    }
                    
                    
            }
        }
    }
    
    
   
    @IBAction func MoreWeather(_ sender: Any) {
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "weatherforecast") as! weatherforecast
        myVC.location_end = point_begin
        navigationController?.pushViewController(myVC, animated: true)
        
        }
    
    
    func getimage(url:String)->UIImage{
        let path = URL(string: url)
        let data = try? Data(contentsOf: path!)
        return UIImage(data: data!)!
    }
 
    func getstringfromdate(date : Date) -> String{
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "MM/dd/EEE HH:mm"
        
        let now = dateformatter.string(from: date)
        return now
        
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


