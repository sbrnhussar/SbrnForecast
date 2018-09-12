//
//  ViewController.swift
//  SbrnForecast
//
//  Created by Mac_mini on 29.08.2018.
//  Copyright © 2018 Mac_mini. All rights reserved.
//

import UIKit


class CitiesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK: Variables
    
    @IBOutlet weak var cities_table_view: UITableView!
    @IBOutlet weak var new_city_field: UITextField!
    var cities: [City] = []
    static var first_load: Bool = false
    
    
    //MARK: Navigation
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_identifier = "CitiesTableViewCell"
        
        
        guard let cell = cities_table_view.dequeueReusableCell(withIdentifier: cell_identifier, for: indexPath) as? CitiesTableViewCell else {
            fatalError("The dequeued cell is not an instance of CitiesTableViewCell.")      }
        
        let city = cities[indexPath.row]
        
        cell.city_label.text = "\(city.get_name()), \(city.get_region()), \(city.get_country())"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conn = SQLiteConnection()
        conn.set_default_city(by: cities[indexPath.row].get_woeid())
        
        open_forecast_vc(for: cities[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let conn = SQLiteConnection()
            conn.delete_city(this: cities[indexPath.row])
            cities.remove(at: indexPath.row)
            cities_table_view.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //MARK: Actions
    
    @IBAction func click_add_button(_ sender: UIButton) {
        if new_city_field.text != ""{
            add_city(by: new_city_field.text!)
        }
        else{
            new_city_field.placeholder = "Try again, empty name..."
        }
        new_city_field.text = ""
    }
    
    
    //MARK: Private methods
    
    private func open_forecast_vc(for selected_city: City){
        
        let forecast_vc = self.storyboard?.instantiateViewController(withIdentifier: "ForecastVC") as! ForecastVC
        
        forecast_vc.city = selected_city
        
        self.present(forecast_vc, animated: true, completion: nil)
    }
    
    private func add_city(by name: String){
        
        let woeid_url_str = "https://query.yahooapis.com/v1/public/yql?q=select%20woeid%20from%20geo.places(1)%20where%20text%3D%22\(name.lowercased())%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
        
        if let woeid_url = URL(string: woeid_url_str){
            let woeid_task = URLSession.shared.dataTask(with: woeid_url) {
                (woeid_data, woeid_response, woeid_error) in
                
                if woeid_data != nil {
                    let decoder = JSONDecoder()
                    let woeid_answer = try! decoder.decode(CityResponse.self, from: woeid_data!)
                    
                    DispatchQueue.main.async {
                        let woeid = Int(woeid_answer.query.results.place.woeid)!
                        
                        
                        let forecast_url_str = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20u%20%3D%20'c'%20and%20woeid%20%3D%20\(String(describing: woeid))&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
                        
                        let forecast_url = URL(string: forecast_url_str)
                        
                        
                        let forecast_task = URLSession.shared.dataTask(with: forecast_url!) {
                            (forecast_data, forecast_response, forecast_error) in
                            
                            if forecast_data != nil {
                                
                                let decoder = JSONDecoder()
                                let forecast_answer = try! decoder.decode(ForecastResponse.self, from: forecast_data!)
                                
                                //  Fill city info
                                let name = forecast_answer.query.results.channel.location.city
                                let region = forecast_answer.query.results.channel.location.region
                                let country = forecast_answer.query.results.channel.location.country
                                
                                //  Fill the forecast
                                let date_formatter = DateFormatter()
                                date_formatter.dateFormat = "dd MMM yyyy"
                                
                                let curr_forecast = FullForecast(set_date: date_formatter.date(from: forecast_answer.query.results.channel.item.forecast[0].date)!, set_description: forecast_answer.query.results.channel.item.forecast[0].text, set_low_temp: Int(forecast_answer.query.results.channel.item.forecast[0].low)!, set_high_temp: Int(forecast_answer.query.results.channel.item.forecast[0].high)!, set_avg_temp: Int(forecast_answer.query.results.channel.item.condition.temp)!, set_humidity: Int(forecast_answer.query.results.channel.atmosphere.humidity)!, set_wind_speed: Float(forecast_answer.query.results.channel.wind.speed)!, set_sunrise: forecast_answer.query.results.channel.astronomy.sunrise, set_sunset: forecast_answer.query.results.channel.astronomy.sunset)
                                
                                
                                var week_forecast = [DailyForecast]()
                                week_forecast.append(curr_forecast)
                                
                                for i in 1..<forecast_answer.query.results.channel.item.forecast.count{
                                    week_forecast.append(DailyForecast(set_date: date_formatter.date(from: forecast_answer.query.results.channel.item.forecast[i].date)!, set_description: forecast_answer.query.results.channel.item.forecast[i].text, set_low_temp: Int(forecast_answer.query.results.channel.item.forecast[i].low)!, set_high_temp: Int(forecast_answer.query.results.channel.item.forecast[i].high)!))
                                }
                                
                                DispatchQueue.main.async {
                                    
                                    let city = City(set_woeid: woeid, set_name: name, set_region: region, set_country: country, set_week_forecast: week_forecast)
                                    
                                    let conn = SQLiteConnection()
                                    
                                    if  conn.check_existence_city(by: city.get_woeid()) {
                                        
                                        conn.update(this: city)
                                    }
                                    else {
                                        
                                        conn.insert(this: city)
                                        
                                        let newIndexPath = IndexPath(row: self.cities.count, section: 0)
                                        
                                        self.cities.append(city)
                                        
                                        self.cities_table_view.insertRows(at: [newIndexPath], with: .automatic)
                                        
                                        let conn = SQLiteConnection()
                                        conn.set_default_city(by: city.get_woeid())
                                        
                                        self.open_forecast_vc(for: city)
                                    }
                                }
                            }
                        }
                        forecast_task.resume()
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
            woeid_task.resume()
        }
        else{
            new_city_field.placeholder = "Try again, wrong name..."
        }
        new_city_field.placeholder = "Enter the city name..."
        new_city_field.text = ""
        
    }
    
    
    //MARK: Superclass functions
    
    override func viewWillAppear(_ animated: Bool) {
        
        let conn = SQLiteConnection()
        
        cities = conn.load_cities()
        
        for city in cities{
            city.update()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let conn = SQLiteConnection()
        
        let default_woeid = conn.get_default_woeid()
        
        if !CitiesVC.first_load && default_woeid != nil {
            for city in cities{
                if city.get_woeid() == default_woeid!{
                    open_forecast_vc(for: city)
                    break
                }
            }
        }
        CitiesVC.first_load = true
    }
}
