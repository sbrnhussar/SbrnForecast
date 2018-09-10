//
//  YahooResponseStruct.swift
//  SbrnForecast
//
//  Created by Mac_mini on 29.08.2018.
//  Copyright © 2018 Mac_mini. All rights reserved.
//

import Foundation

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
