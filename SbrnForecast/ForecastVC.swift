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
                    let decoder = JSONDecoder()
                    let answer = try! decoder.decode(ForecastResponse.self, from: data!)
                    
                    DispatchQueue.main.async {
                        //  Fill name of city
                        let name: String = answer.query.results.channel.location.city
                        let region: String = answer.query.results.channel.location.region
                        let country: String = answer.query.results.channel.location.country
                        
                        //  Fill the forecast
                        let date_formatter = DateFormatter()
                        date_formatter.dateFormat = "dd MMM yyyy"
                        
                        let curr_forecast = FullForecast(set_date: date_formatter.date(from: answer.query.results.channel.item.forecast[0].date)!, set_description: answer.query.results.channel.item.forecast[0].text, set_low_temp: Int(answer.query.results.channel.item.forecast[0].low)!, set_high_temp: Int(answer.query.results.channel.item.forecast[0].high)!, set_avg_temp: Int(answer.query.results.channel.item.condition.temp)!, set_humidity: Int(answer.query.results.channel.atmosphere.humidity)!, set_wind_speed: Float(answer.query.results.channel.wind.speed)!, set_sunrise: answer.query.results.channel.astronomy.sunrise, set_sunset: answer.query.results.channel.astronomy.sunset)
                        
                        var week_forecast = [DailyForecast]()
                        week_forecast.append(curr_forecast)
                        
                        for i in 1..<answer.query.results.channel.item.forecast.count{
                            week_forecast.append(DailyForecast(set_date: date_formatter.date(from: answer.query.results.channel.item.forecast[i].date)!, set_description: answer.query.results.channel.item.forecast[i].text, set_low_temp: Int(answer.query.results.channel.item.forecast[i].low)!, set_high_temp: Int(answer.query.results.channel.item.forecast[i].high)!))
                        }
                        
                        DispatchQueue.main.async {
                            self.city = City(set_woeid: self.city.get_woeid(), set_name: name, set_region: region, set_country: country, set_week_forecast: week_forecast)
                            
                            let conn = SQLiteConnection()
                            conn.update(this: self.city)
                            
                            self.set_data(from: self.city)
                            
                            self.daily_forecast_table_view.reloadData()
                            
                            self.activity_indicator_view.stopAnimating()
                        }
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
    
    private func set_data(from city: City){
        
        city_label.text = "Forecast for \(city.get_name())"
        region_label.text = "\(city.get_region()), \(city.get_country())"
        let curr_forecast = city.get_week_forecast()[0]
        if curr_forecast.check_full_forecast(){
            avg_temp_label.text = "\(curr_forecast.get_avg_temp()!) ℃"
            humidity_label.text = "Humidity: \(curr_forecast.get_humidity()!)%"
            wind_label.text = "Wind speed: \(curr_forecast.get_wind_speed()!) m/s"
            sun_label.text = "Sunrise \(curr_forecast.get_sunrise()!)\t|\tSunset \(curr_forecast.get_sunset()!)"
        }
        else{
            avg_temp_label.text = "\(curr_forecast.get_high_temp() - curr_forecast.get_low_temp()) ℃"
            humidity_label.text = "Humidity: --%"
            wind_label.text = "Wind speed: -- km/h"
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
        super.viewDidAppear(true)
        activity_indicator_view.center = self.view.center
        activity_indicator_view.isHidden = true
        activity_indicator_view.hidesWhenStopped = true
        activity_indicator_view.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        set_data(from: city)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
