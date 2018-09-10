//
//  City.swift
//  SbrnForecast
//
//  Created by Mac_mini on 29.08.2018.
//  Copyright © 2018 Mac_mini. All rights reserved.
//

import Foundation

class City {
    
    
    // MARK: Variables
    
    private var woeid: Int
    private var name, region, country: String
    private var week_forecast: [DailyForecast]
    
    
    // MARK: Initialization
    
    public init(){
        woeid = 0
        name = "unknown city"
        region = "unknown region"
        country = "unknown country"
        week_forecast = [DailyForecast]()
    }
    
    public init(set_woeid: Int, set_name: String, set_region: String, set_country: String, set_week_forecast: [DailyForecast]){
        woeid = set_woeid
        name = set_name
        region = set_region
        country = set_country
        week_forecast = set_week_forecast
    }
    
    
    // MARK: GET-functions
    
    public func get_woeid() -> Int{
        return woeid
    }
    
    public func get_name() -> String{
        return name
    }
    
    public func get_region() -> String{
        return region
    }
    
    public func get_country() -> String{
        return country
    }
    
    public func get_week_forecast() -> [DailyForecast]{
        return week_forecast
    }
    
    
    //MARK: Methods
    public func update(){
        
        if let url = URL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20u%20%3D%20'c'%20and%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20woeid%3D%22\(woeid)%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"){
            
            let task = URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                
                if data != nil {
                    let decoder = JSONDecoder()
                    let answer = try! decoder.decode(ForecastResponse.self, from: data!)
                    
                    DispatchQueue.main.async {
                        //  Fill name of city
                        self.name = answer.query.results.channel.location.city
                        self.region = answer.query.results.channel.location.region
                        self.country = answer.query.results.channel.location.country
                        
                        //  Fill the forecast
                        let date_formatter = DateFormatter()
                        date_formatter.dateFormat = "dd MMM yyyy"
                        
                        let curr_forecast = FullForecast(set_date: date_formatter.date(from: answer.query.results.channel.item.forecast[0].date)!, set_description: answer.query.results.channel.item.forecast[0].text, set_low_temp: Int(answer.query.results.channel.item.forecast[0].low)!, set_high_temp: Int(answer.query.results.channel.item.forecast[0].high)!, set_avg_temp: Int(answer.query.results.channel.item.condition.temp)!, set_humidity: Int(answer.query.results.channel.atmosphere.humidity)!, set_wind_speed: Float(answer.query.results.channel.wind.speed)!, set_sunrise: answer.query.results.channel.astronomy.sunrise, set_sunset: answer.query.results.channel.astronomy.sunset)
                        
                        self.week_forecast.removeAll()
                        self.week_forecast.append(curr_forecast)
                        
                        for i in 1..<answer.query.results.channel.item.forecast.count{
                            self.week_forecast.append(DailyForecast(set_date: date_formatter.date(from: answer.query.results.channel.item.forecast[i].date)!, set_description: answer.query.results.channel.item.forecast[i].text, set_low_temp: Int(answer.query.results.channel.item.forecast[i].low)!, set_high_temp: Int(answer.query.results.channel.item.forecast[i].high)!))
                        }
                        
                        let conn = SQLiteConnection()
                        conn.update(this: self)
                    }
                }
            }
            task.resume()
        }
    }
}
