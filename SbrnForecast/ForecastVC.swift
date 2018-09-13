//
//  ForecastVC.swift
//  SbrnForecast
//
//  Created by Mac_mini on 29.08.2018.
//  Copyright © 2018 Mac_mini. All rights reserved.
//

import UIKit

class ForecastVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var activity_indicator_view: UIActivityIndicatorView!
    
    @IBOutlet weak var city_label: UILabel!
    @IBOutlet weak var region_label: UILabel!
    @IBOutlet weak var curr_date_label: UILabel!
    @IBOutlet weak var avg_temp_label: UILabel!
    @IBOutlet weak var descript_label: UILabel!
    @IBOutlet weak var humidity_label: UILabel!
    @IBOutlet weak var wind_label: UILabel!
    @IBOutlet weak var sun_label: UILabel!
    
    @IBOutlet weak var daily_forecast_table_view: UITableView!
    
    var city: City = City()
    
    //MARK: Navigation
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return city.get_week_forecast().count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_identifier = "DailyForecastTableViewCell"
        
        
        guard let cell = daily_forecast_table_view.dequeueReusableCell(withIdentifier: cell_identifier, for: indexPath) as? DailyForecastTableViewCell
        else {
            fatalError("The dequeued cell is not an instance of DailyForecastTableViewCell.")
        }
        
        let forecast = city.get_week_forecast()[indexPath.row]
        
        cell.description_label.text = forecast.get_description()
        cell.temp_label.text = "\(forecast.get_low_temp())..\(forecast.get_high_temp()) ℃"
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, EEE"
        cell.date_label.text = formatter.string(from: forecast.get_date())
        
        return cell
        
    }
    
    
    //MARK: Actions
    @IBAction func click_manage(_ sender: UIButton) {
        
        let cities_vc = self.storyboard?.instantiateViewController(withIdentifier: "CitiesVC") as! CitiesVC
        
        let conn = SQLiteConnection()
        
        cities_vc.cities = conn.load_cities()
        
        self.present(cities_vc, animated: true, completion: nil)
    }
    
    @IBAction func swipe_down(_ sender: Any) {
        refresh_view_data()
    }
    
    
    //MARK: Private methods
    private func refresh_view_data(){
        
        activity_indicator_view.startAnimating()
        
        if let url = URL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20u%20%3D%20'c'%20and%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20woeid%3D%22\(city.get_woeid())%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"){
            
            let task = URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                
                if data != nil {
                    
                    DispatchQueue.main.async {
                        self.city = distribute(by: self.city.get_woeid(), info: data!)
                        
                        let conn = SQLiteConnection()
                        conn.update(this: self.city)
                        
                        self.set_data(from: self.city)
                        
                        self.daily_forecast_table_view.reloadData()
                        
                        self.activity_indicator_view.stopAnimating()
                    }
                }
                else{
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "There isn't the Internet connection", message: "Please, fix it and try again.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        
                        self.present(alert, animated: true)
                    }
                }
            }
            task.resume()
        }
    }
    
    private func transform_direction(from number: Int) -> String{
        
        var string_direction: String = "undefined"
        
        if number > 338 || number <= 23 {
            string_direction = "N"
        }
        else if number > 23 || number <= 68 {
            string_direction = "NE"
        }
        else if number > 68 || number <= 113 {
            string_direction = "E"
        }
        else if number > 113 || number <= 158 {
            string_direction = "SE"
        }
        else if number > 158 || number <= 203 {
            string_direction = "S"
        }
        else if number > 203 || number <= 248 {
            string_direction = "SW"
        }
        else if number > 248 || number <= 293 {
            string_direction = "W"
        }
        else if number > 293 || number <= 338 {
            string_direction = "NW"
        }
        
        return string_direction
    }
    
    private func set_data(from city: City){
        
        region_label.text = "\(city.get_region()), \(city.get_country())"
        let curr_forecast = city.get_week_forecast()[0]
        if curr_forecast.check_full_forecast(){
            city_label.text = "Forecast for \(city.get_name())"
            avg_temp_label.text = "\(curr_forecast.get_avg_temp()!) ℃"
            humidity_label.text = "Humidity: \(curr_forecast.get_humidity()!)%"
            
            wind_label.text = "Wind: \(curr_forecast.get_wind_speed()!) km/h to \(transform_direction(from: curr_forecast.get_wind_direction()!))"
            sun_label.text = "Sunrise \(curr_forecast.get_sunrise()!)\t|\tSunset \(curr_forecast.get_sunset()!)"
        }
        else{
            city_label.text = "Forecast(offline) for \(city.get_name())"
            avg_temp_label.text = "\(curr_forecast.get_high_temp() - curr_forecast.get_low_temp()) ℃"
            humidity_label.text = "Humidity: --%"
            wind_label.text = "Wind speed: -- km/h to -"
            sun_label.text = "Sunrise --:--\t|\tSunset --:--"
        }
        descript_label.text = curr_forecast.get_description()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, EEE"
        curr_date_label.text = formatter.string(from: curr_forecast.get_date())
        
    }
    
    
    //MARK: Superclass functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "clouds.jpg")!)
        self.daily_forecast_table_view.backgroundColor = UIColor.init(named: "GreyBlue")
        super.viewWillAppear(true)
        activity_indicator_view.center = self.view.center
        activity_indicator_view.isHidden = true
        activity_indicator_view.hidesWhenStopped = true
        activity_indicator_view.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        refresh_view_data()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
