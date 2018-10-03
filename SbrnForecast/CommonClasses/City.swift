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
}
