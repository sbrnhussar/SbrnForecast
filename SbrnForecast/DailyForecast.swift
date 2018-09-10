//
//  DailyForecast.swift
//  SbrnForecast
//
//  Created by Mac_mini on 29.08.2018.
//  Copyright © 2018 Mac_mini. All rights reserved.
//

import Foundation


//  For storing info about daily forecasts
class DailyForecast {
    
    
    //MARK: DailyForecast variables
    
    private var description: String?
    private var low_temp, high_temp: Int?
    private var date: Date?
    
    
    //MARK: DailyForecast init
    
    public init(){
        description = nil
        low_temp = nil
        high_temp = nil
        date = nil
    }
    
    public init(set_date: Date,  set_description: String, set_low_temp: Int, set_high_temp: Int){
        date = set_date
        description = set_description
        low_temp = set_low_temp
        high_temp = set_high_temp
    }
    
    public init(copying_forecast: DailyForecast){
        date = copying_forecast.get_date()
        description = copying_forecast.get_description()
        low_temp = copying_forecast.get_low_temp()
        high_temp = copying_forecast.get_high_temp()
    }
    
    
    //MARK: DailyForecast GET-functions
    
    public func get_date() -> Date{
        return date!
    }
    
    public func get_description() -> String{
        return description!
    }
    
    public func get_low_temp() -> Int{
        return low_temp!
    }
    
    public func get_high_temp() -> Int{
        return high_temp!
    }
    
    public func get_avg_temp() -> Int?{
        return nil
    }
    
    public func get_humidity() -> Int?{
        return nil
    }
    
    public func get_wind_speed() -> Float?{
        return nil
    }
    
    public func get_sunrise() -> String?{
        return nil
    }
    
    public func get_sunset() -> String?{
        return nil
    }
    
    
    //MARK: Methods
    
    public func check_full_forecast() -> Bool{
        if self.get_avg_temp() == nil || self.get_humidity() == nil || self.get_wind_speed() == nil || self.get_sunrise() == nil || self.get_sunset() == nil {
            return false
        }
        else{
            return true
        }
    }
}




//  For storing extended info
class FullForecast: DailyForecast{
    
    
    //MARK: FullForecast variables
    
    private var avg_temp, humidity: Int?
    private var wind_speed: Float?
    private var sunrise, sunset: String?
    
    
    //MARK: FullForecast init
    
    override public init(){
        avg_temp = nil
        humidity = nil
        wind_speed = nil
        sunrise = nil
        sunset = nil
        super.init()
    }
    
    public init(set_date: Date,  set_description: String, set_low_temp: Int, set_high_temp: Int, set_avg_temp: Int, set_humidity: Int, set_wind_speed: Float, set_sunrise: String, set_sunset: String){
        avg_temp = set_avg_temp
        humidity = set_humidity
        wind_speed = set_wind_speed
        sunrise = set_sunrise
        sunset = set_sunset
        super.init(set_date: set_date,  set_description: set_description, set_low_temp: set_low_temp, set_high_temp: set_high_temp)
    }
    
    public init(copying_forecast: FullForecast){
        avg_temp = copying_forecast.get_avg_temp()
        humidity = copying_forecast.get_humidity()
        wind_speed = copying_forecast.get_wind_speed()
        sunrise = copying_forecast.get_sunrise()
        sunset = copying_forecast.get_sunset()
        super.init(set_date: copying_forecast.get_date(),  set_description: copying_forecast.get_description(), set_low_temp: copying_forecast.get_low_temp(), set_high_temp: copying_forecast.get_high_temp())
    }
    
    override public init(copying_forecast: DailyForecast){
        avg_temp = nil
        humidity = nil
        wind_speed = nil
        sunrise = nil
        sunset = nil
        super.init(set_date: copying_forecast.get_date(),  set_description: copying_forecast.get_description(), set_low_temp: copying_forecast.get_low_temp(), set_high_temp: copying_forecast.get_high_temp())
    }
    
    
    //MARK: FullForecast GET-functions
    
    public override func get_avg_temp() -> Int{
        return avg_temp!
    }
    
    public override func get_humidity() -> Int{
        return humidity!
    }
    
    public override func get_wind_speed() -> Float{
        return wind_speed!
    }
    
    public override func get_sunrise() -> String{
        return sunrise!
    }
    
    public override func get_sunset() -> String{
        return sunset!
    }
}
