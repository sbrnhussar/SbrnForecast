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
    
    public init(copying_city: City){
        woeid = copying_city.get_woeid()
        name = copying_city.get_name()
        region = copying_city.get_region()
        country = copying_city.get_country()
        week_forecast = copying_city.get_week_forecast()
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
                    DispatchQueue.main.async {
                        
                        let buff_city = distribute(by: self.get_woeid(), info: data!)
                        
                        //  Fill name of city
                        self.name = buff_city.get_name()
                        self.region = buff_city.get_region()
                        self.country = buff_city.get_country()
                        
                        self.week_forecast = buff_city.get_week_forecast()
                        
                        let conn = SQLiteConnection()
                        conn.update(this: self)
                    }
                }
            }
            task.resume()
        }
    }
}
