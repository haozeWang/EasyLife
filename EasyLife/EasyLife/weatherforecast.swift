//
//  weatherforecast.swift
//  EasyLife
//
//  Created by 王昊泽 on 17/3/10.
//  Copyright © 2017年 Haoze Wang. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class weatherforecast: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource {

   
    
    
    @IBOutlet weak var curr_temp: UILabel!
    @IBOutlet weak var wea_inf: UILabel!
    @IBOutlet weak var cityname: UILabel!
    @IBOutlet weak var UIimageview: UIImageView!
    @IBOutlet weak var UItableView: UITableView!
    @IBOutlet weak var UICollectionView: UICollectionView!
    var location_end = "chicago"
    var weatherdata = [Weather]()
    var curr_weather : Weather!
    var weather_day = [Weather]()
    var city : String!
    var cn : String!
    var object = [AnyObject](){
        willSet{
            let date = NSDate()
            var time = Int(date.timeIntervalSince1970)
            time = time - 21800
            DispatchQueue.main.async{
                self.weatherdata.removeAll()
                for i in newValue{
                    if i["dt"] as! Int > time {
                        let dt = i["dt"]
                        let wea = i["weather"] as! [AnyObject]
                        let weather_clear = wea[0] as AnyObject
                        let weather_date = weather_clear["main"] as! String
                        let image = weather_clear["icon"] as! String
                        let dt_txt = i["dt_txt"] as! String
                        let tem = (i["main"] as! [String: AnyObject])["temp"] as! Int
                        let temp = Weather(city: self.city, country: self.cn, weather: weather_date, temperature: tem, image: image)
                        temp.dt = dt as! Int!
                        temp.time = dt_txt.dttotime()
                        self.weatherdata.append(temp)
                    }
 
                }
                self.getfutureday()
                self.UICollectionView?.reloadData()
            }
            
        }
        didSet{
            object.removeAll()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = NSDate()
        self.UICollectionView.backgroundColor = UIColor.clear
        self.UItableView.separatorStyle = .none
        let  time = Int(date.timeIntervalSince1970)
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        let num = time % 4
        if(num == 0){
           backgroundImage.image = UIImage(named: "1.jpg")
        }
        else if(num == 1){
            backgroundImage.image = UIImage(named: "2.jpg")
        }
        else if(num == 2){
            backgroundImage.image = UIImage(named: "3.jpg")
        }
        else{
            backgroundImage.image = UIImage(named: "4.jpg")
        }
        self.view.insertSubview(backgroundImage, at: 0)
        self.UICollectionView.delegate = self
        self.UICollectionView.dataSource = self
        self.UItableView.dataSource = self
        self.UItableView.delegate = self
        getdata()
        getcurrdata()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getdata(){
       let  url = "http://api.openweathermap.org/data/2.5/forecast?\(location_end)&appid=e5ad7ed727b66d69dc3c323ad8b8fd71"
        SharedNetwork.SharedInstance.grabSomeData(url){(response) -> Void in
            
            DispatchQueue.main.async
                {
                    if let responsedate = response?["list"] as? [AnyObject]
                    {
                        self.object = responsedate as [AnyObject]
                        self.city = (response?["city"] as! [String: AnyObject])["name"] as! String
                        self.cn = (response?["city"] as! [String: AnyObject])["country"] as! String
                    }
            }
            
        }
    }
    
    func getcurrdata(){
        
    let url = "http://api.openweathermap.org/data/2.5/weather?\(location_end)&appid=e5ad7ed727b66d69dc3c323ad8b8fd71"
    
    
    SharedNetwork.SharedInstance.grabSomeData(url){(response) -> Void in
    
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
            self.curr_weather = Weather(city: city, country: country, weather: weather_date, temperature: temperature, image: code)
            self.curr_temp.text = "\(temperature - 273)℃"
            self.wea_inf.text = weather_date
            self.cityname.text = city
    
        }
    
    
        }
    }
}
    
    func getfutureday(){
        var date = NSDate()
        for i in weatherdata{
            let temp =  NSDate(timeIntervalSince1970: Double(i.dt))
            if(!NSCalendar.current.isDate(date as Date, inSameDayAs:temp as Date)){
                print("this if afla")
                weather_day.append(i)
                date = temp
            }
        }
        UItableView.reloadData()
        print(weather_day.count)
    }

    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! weatherforecastcell
        
        let datacell = self.weatherdata[indexPath.row]
        cell.UItempLabel.text = "\(datacell.temperature - 273)℃"
        cell.UIdateLabel.text = datacell.time
        cell.UIimageView.image = self.getimage(url: "http://openweathermap.org/img/w/\(datacell.image as String).png")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weather_day.count;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.UItableView.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as!weatherforecastTableViewCell
        let Issue = weather_day[indexPath.row]
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        let temp =  NSDate(timeIntervalSince1970: Double(Issue.dt))
        cell.UIdatelabel.text = temp.dayOfTheWeek()! as String
        cell.UItemp.text = "\(Issue.temperature - 273)℃"
        cell.UIweather.image = self.getimage(url: "http://openweathermap.org/img/w/\(Issue.image as String).png")
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherdata.count
    }
    
    
    func getimage(url:String)->UIImage{
        let path = URL(string: url)
        let data = try? Data(contentsOf: path!)
        return UIImage(data: data!)!
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

extension String{
    func dttotime() -> String{
        let start = self.index(self.startIndex, offsetBy: 11)
        let end = self.index(self.endIndex, offsetBy: -6)
        let range = start..<end
        
       return self.substring(with: range)
    }
}

extension NSDate{
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        
        var isGreater = false
        
        
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        
        return isGreater
    }

}

extension NSDate {
    func dayOfTheWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self as Date)
    }
}

