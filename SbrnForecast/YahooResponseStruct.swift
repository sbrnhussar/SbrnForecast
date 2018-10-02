//
//  YahooResponseStruct.swift
//  SbrnForecast
//
//  Created by Mac_mini on 29.08.2018.
//  Copyright © 2018 Mac_mini. All rights reserved.
//

import Foundation

//  Distridutes values to City object's fields
func distribute_data(by woeid: Int, info: Data) -> City{
    
    let decoder = JSONDecoder()
    let answer = try! decoder.decode(ForecastResponse.self, from: info)
    
    //  Fill name of city
    let name: String = answer.query.results.channel.location.city
    let region: String = answer.query.results.channel.location.region
    let country: String = answer.query.results.channel.location.country
    
    //  Fill the forecast
    let date_formatter = DateFormatter()
    date_formatter.dateFormat = "dd MMM yyyy"
    
    
    
    let curr_forecast = FullForecast(set_date: date_formatter.date(from: answer.query.results.channel.item.forecast[0].date)!, set_description: answer.query.results.channel.item.forecast[0].text, set_low_temp: Int(answer.query.results.channel.item.forecast[0].low)!, set_high_temp: Int(answer.query.results.channel.item.forecast[0].high)!, set_avg_temp: Int(answer.query.results.channel.item.condition.temp)!, set_humidity: Int(answer.query.results.channel.atmosphere.humidity)!, set_wind_speed: Float(answer.query.results.channel.wind.speed)!, set_wind_direction: Int(answer.query.results.channel.wind.direction)!, set_sunrise: answer.query.results.channel.astronomy.sunrise, set_sunset: answer.query.results.channel.astronomy.sunset)
    
    var week_forecast = [DailyForecast]()
    week_forecast.append(curr_forecast)
    
    for i in 1..<answer.query.results.channel.item.forecast.count{
        week_forecast.append(DailyForecast(set_date: date_formatter.date(from: answer.query.results.channel.item.forecast[i].date)!, set_description: answer.query.results.channel.item.forecast[i].text, set_low_temp: Int(answer.query.results.channel.item.forecast[i].low)!, set_high_temp: Int(answer.query.results.channel.item.forecast[i].high)!))
    }
    
    return City(set_woeid: woeid, set_name: name, set_region: region, set_country: country, set_week_forecast: week_forecast)
}

//  Structure for parsing a response about city's woeid
struct CityResponse: Codable{
    
    var query: Query
    struct Query: Codable {
        
        let results: Results
        struct Results: Codable {
            
            let place: Place
            struct Place: Codable {
                
                let woeid: String
            }
        }
    }
}

//  Structure for parsing a city's forecast
struct ForecastResponse: Codable{
    
    var query: Query
    struct Query: Codable {
        
        let results: Results
        struct Results: Codable {
            
            let channel: Channel
            struct Channel: Codable {
                
                let units: Units
                struct Units: Codable {
                    let distance: String
                    let pressure: String
                    let speed: String
                    let temperature: String
                }
                
                let location: Location
                struct Location: Codable {
                    let city: String
                    let country: String
                    let region: String
                }
                
                let wind: Wind
                struct Wind: Codable {
                    let speed: String
                    let direction: String
                }
                
                let atmosphere: Atmosphere
                struct Atmosphere: Codable {
                    let humidity: String
                }
                
                let astronomy: Astronomy
                struct Astronomy: Codable {
                    let sunrise: String
                    let sunset: String
                }
                
                let item: Item
                struct Item: Codable {
                    
                    let condition: Condition
                    struct Condition: Codable {
                        let date: String
                        let temp: String
                        let text: String
                    }
                    
                    let forecast: [Forecast]
                    struct Forecast: Codable {
                        let date: String
                        let day: String
                        let high: String
                        let low: String
                        let text: String
                    }
                }
            }
        }
    }
}
