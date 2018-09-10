//
//  SQLiteConnection.swift
//  SbrnForecast
//
//  Created by Mac_mini on 29.08.2018.
//  Copyright © 2018 Mac_mini. All rights reserved.
//

import Foundation
import SQLite3

class SQLiteConnection{
    
    private static var db: OpaquePointer? = nil
    
    //MARK: like "get instance"
    
    public static func get_connection () -> OpaquePointer{
        
        if db == nil {
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) .appendingPathComponent("SbrnForecast.sqlite")
            
            var buff_db: OpaquePointer?
            
            let fileURL1 = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) .appendingPathComponent("SbrnWeather.sqlite")
            
            var buff_db1: OpaquePointer?
            
            if sqlite3_open(fileURL1.path, &buff_db1) != SQLITE_OK {
                print("error opening database")
            }
            else{
                DROP(dropped_db: buff_db1!)
            }
            
            if sqlite3_open(fileURL.path, &buff_db) != SQLITE_OK {
                print("error opening database")
            }
            else{
                
                let create_table_query_city = "CREATE TABLE IF NOT EXISTS city (woeid INTEGER PRIMARY KEY NOT NULL, name TEXT NOT NULL, region TEXT NOT NULL, country TEXT NOT NULL)"
                
                if sqlite3_exec(buff_db, create_table_query_city, nil, nil, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(buff_db)!)
                    print("error creating table: \(errmsg)")
                }
                else{
                    let create_table_query_default_city = "CREATE TABLE IF NOT EXISTS default_city (woeid INTEGER PRIMARY KEY NOT NULL)"
                    if sqlite3_exec(buff_db, create_table_query_default_city, nil, nil, nil) != SQLITE_OK {
                        let errmsg = String(cString: sqlite3_errmsg(buff_db)!)
                        print("error creating table: \(errmsg)")
                    }
                    else{
                        let create_table_query_daily_forecast = "CREATE TABLE IF NOT EXISTS daily_forecast (forecast_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, woeid INTEGER NOT NULL, date TEXT NOT NULL, description TEXT NOT NULL, low_temp INTEGER NOT NULL, high_temp INTEGER NOT NULL)"
                        if sqlite3_exec(buff_db, create_table_query_daily_forecast, nil, nil, nil) != SQLITE_OK {
                            let errmsg = String(cString: sqlite3_errmsg(buff_db)!)
                            print("error creating table: \(errmsg)")
                        }
                        else{
                            let create_table_query_full_forecast = "CREATE TABLE IF NOT EXISTS full_forecast (ff_id INTEGER PRIMARY KEY AUTOINCREMENT, forecast_id INTEGER NOT NULL, avg_temp INTEGER NOT NULL, humidity INTEGER NOT NULL, wind_speed REAL NOT NULL, sunrise TEXT NOT NULL, sunset TEXT NOT NULL)"
                            if sqlite3_exec(buff_db, create_table_query_full_forecast, nil, nil, nil) != SQLITE_OK {
                                let errmsg = String(cString: sqlite3_errmsg(buff_db)!)
                                print("error creating table: \(errmsg)")
                            }
                            else{
                                db = buff_db!
                            }
                        }
                    }
                }
            }
        }
        return db!
    }
    
    private static func DROP(dropped_db: OpaquePointer){
        if sqlite3_exec(dropped_db, "DROP table if exists city", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(dropped_db)!)
            print("error droping table: \(errmsg)")
        }
        
        if sqlite3_exec(dropped_db, "DROP table if exists day_weather", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(dropped_db)!)
            print("error droping table: \(errmsg)")
        }
        
        if sqlite3_exec(dropped_db, "DROP table if exists full_day_weather", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(dropped_db)!)
            print("error droping table: \(errmsg)")
        }
    }
    
    
    //MARK: CRUD manipulation
    
    
    //  Checking city by woeid
    
    public func check_existence_city(by woeid: Int) -> Bool {
        let conn = SQLiteConnection.get_connection()
        let select_woeid_query = "SELECT woeid FROM city"
        
        var select_woeid_statement: OpaquePointer? = nil
        
        sqlite3_prepare_v2(conn, select_woeid_query, -1, &select_woeid_statement, nil)
        
        var existing_flag = false;
        while sqlite3_step(select_woeid_statement) == SQLITE_ROW {
            if Int(sqlite3_column_int(select_woeid_statement, 0)) == woeid {
                existing_flag = true
            }
        }
        return existing_flag;
    }
    
    
    //  Interaction with city by default
    
    public func set_default_city(by woeid: Int){
        
        let conn = SQLiteConnection.get_connection()
        
        let unset_default_city_query = "DELETE FROM default_city"
        
        if sqlite3_exec(conn, unset_default_city_query, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(conn)!)
            print("DELETE ERROR - DEFAULT_CITY: \(errmsg)")
        }
        else{
            let set_default_city_query = "INSERT INTO default_city VALUES(\(woeid))"
            if sqlite3_exec(conn, set_default_city_query, nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(conn)!)
                print("INSERT ERROR - DEFAULT_CITY: \(errmsg)")
            }
        }
    }
    
    public func unset_default_city(){
        
        let conn = SQLiteConnection.get_connection()
        
        let unset_default_city_query = "DELETE FROM default_city"
        
        if sqlite3_exec(conn, unset_default_city_query, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(conn)!)
            print("DELETE ERROR - DEFAULT_CITY: \(errmsg)")
        }
    }
    
    public func get_default_woeid() -> Int?{
        
        let conn = SQLiteConnection.get_connection()
        
        let select_woeid_query = "SELECT woeid FROM default_city"
        
        var select_woeid_statement: OpaquePointer? = nil
        
        sqlite3_prepare_v2(conn, select_woeid_query, -1, &select_woeid_statement, nil)
        
        var woeid: Int? = nil
        
        if sqlite3_step(select_woeid_statement) == SQLITE_ROW {
            woeid = Int(sqlite3_column_int(select_woeid_statement, 0))
        }
        sqlite3_finalize(select_woeid_statement)
        
        return woeid
    }
    
    
    //MARK: Interaction with city
    
    public func insert(this city: City){
        
        let insert_city_query = "INSERT INTO city VALUES (\(city.get_woeid()), \'\(city.get_name())\', \'\(city.get_region())\', \'\(city.get_country())\')"
        
        let conn = SQLiteConnection.get_connection()
        
        if sqlite3_exec(conn, insert_city_query, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(conn)!)
            print("INSERT ERROR - CITY: \(errmsg)")
        }
        else{
            self.update_forecast(for: city)
        }
    }
    
    public func update(this city: City){
        
        let update_city_query = "UPDATE city SET name = \'\(city.get_name())\', region = \'\(city.get_region())\', country = \'\(city.get_country())\' WHERE woeid = \'\(city.get_woeid())\'"
        
        let conn = SQLiteConnection.get_connection()
        
        if sqlite3_exec(conn, update_city_query, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(conn)!)
            print("UPDATE ERROR - CITY: \(errmsg)")
        }
        else{
            self.update_forecast(for: city)
        }
        
    }
    
    private func update_forecast(for city: City){
        
        let conn = SQLiteConnection.get_connection()
        
        sqlite3_exec(conn, "DELETE FROM full_forecast WHERE forecast_id IN (SELECT forecast_id FROM daily_forecast WHERE woeid = \(city.get_woeid()))", nil, nil, nil)
        sqlite3_exec(conn, "DELETE FROM daily_forecast WHERE woeid = \(city.get_woeid())", nil, nil, nil)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, EEE"
        
        let week_forecast = city.get_week_forecast()
        for forecast in week_forecast{
            
            let insert_daily_forecast_query = "INSERT INTO daily_forecast (woeid, date, description, low_temp, high_temp) VALUES (\(city.get_woeid()), \'\(formatter.string(from: forecast.get_date()))\', \'\(forecast.get_description())\', \(forecast.get_low_temp()), \(forecast.get_high_temp()))"
            
            if sqlite3_exec(conn, insert_daily_forecast_query, nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(conn)!)
                print("INSERT ERROR - DAY: \(errmsg)")
            }
        }
        
        let select_forecast_query = "SELECT forecast_id FROM daily_forecast WHERE date = \'\(formatter.string(from: week_forecast[0].get_date()))\' AND woeid = \(city.get_woeid())"
        var select_forecast_statement: OpaquePointer? = nil
        sqlite3_prepare_v2(conn, select_forecast_query, -1, &select_forecast_statement, nil)
        
        if sqlite3_step(select_forecast_statement) == SQLITE_ROW {
            let forecast_id = Int(sqlite3_column_int(select_forecast_statement, 0))
            if !week_forecast[0].check_full_forecast() {
                print("INSERT ERROR - FULL: not FullForecast object")
            }
            else{
                let insert_full_forecast_query = "INSERT INTO full_forecast (forecast_id, avg_temp, humidity, wind_speed, sunrise, sunset) VALUES (\(forecast_id), \(week_forecast[0].get_avg_temp()!), \(week_forecast[0].get_humidity()!), \(week_forecast[0].get_wind_speed()!), \'\(week_forecast[0].get_sunrise()!)\', \'\(week_forecast[0].get_sunset()!)\')"
                if sqlite3_exec(conn, insert_full_forecast_query, nil, nil, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(conn)!)
                    print("INSERT ERROR - FULL: \(errmsg)")
                }
            }
        }
    }
    
    public func delete_city(this city: City){
        
        let conn = SQLiteConnection.get_connection()
        
        if sqlite3_exec(conn, "DELETE FROM full_forecast WHERE forecast_id IN (SELECT forecast_id FROM daily_forecast WHERE woeid = \(city.get_woeid()))", nil, nil, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(conn)!)
            print("DELETE ERROR - FULL: \(errmsg)")
        }
        else{
            if sqlite3_exec(conn, "DELETE FROM daily_forecast WHERE woeid = \(city.get_woeid())", nil, nil, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(conn)!)
                print("DELETE ERROR - DAY: \(errmsg)")
            }
            else{
                if sqlite3_exec(conn, "DELETE FROM city WHERE woeid = \(city.get_woeid())", nil, nil, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(conn)!)
                    print("DELETE ERROR - CITY: \(errmsg)")
                }
                else{
                    if sqlite3_exec(conn, "DELETE FROM default_city WHERE woeid = \(city.get_woeid())", nil, nil, nil) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(conn)!)
                        print("DELETE ERROR - DEFAULT_CITY: \(errmsg)")
                    }
                }
            }
        }
        
    }
    
    
    //  Loading manipulation
    
    //  Load forecast by city's woeid
    public func load_forecast(by woeid: Int) -> [DailyForecast]{
        
        let conn = SQLiteConnection.get_connection()
        
        let select_forecast_query = "SELECT * FROM daily_forecast WHERE woeid = \(woeid) ORDER BY date"
        
        var select_forecast_statement: OpaquePointer? = nil
        
        sqlite3_prepare_v2(conn, select_forecast_query, -1, &select_forecast_statement, nil)
        
        var week_forecast = [DailyForecast]()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, EEE"
        
        
        while sqlite3_step(select_forecast_statement) == SQLITE_ROW {
            
            let cal = Calendar(identifier: Calendar.Identifier.gregorian)
            let today = Date()
            let date = formatter.date(from: String(cString: sqlite3_column_text(select_forecast_statement, 2)))!
            
            if cal.compare(date, to: today, toGranularity: .day) == .orderedSame{
                
                let select_full_forecast_query = "SELECT * from full_forecast where forecast_id = \(Int(sqlite3_column_int(select_forecast_statement, 0)))"
                var select_full_forecast_statement: OpaquePointer? = nil
                sqlite3_prepare_v2(conn, select_full_forecast_query, -1, &select_full_forecast_statement, nil)
                
                if sqlite3_step(select_full_forecast_statement) == SQLITE_ROW{
                    week_forecast.append(FullForecast(set_date: formatter.date(from: String(cString: sqlite3_column_text(select_forecast_statement, 2)))!, set_description: String(cString: sqlite3_column_text(select_forecast_statement, 3)), set_low_temp: Int(sqlite3_column_int(select_forecast_statement, 4)), set_high_temp: Int(sqlite3_column_int(select_forecast_statement, 5)), set_avg_temp: Int(sqlite3_column_int(select_full_forecast_statement, 2)), set_humidity: Int(sqlite3_column_int(select_full_forecast_statement, 3)), set_wind_speed: Float(sqlite3_column_double(select_full_forecast_statement, 4)), set_sunrise: String(cString: sqlite3_column_text(select_full_forecast_statement, 5)), set_sunset: String(cString: sqlite3_column_text(select_full_forecast_statement, 6))))
                }
                else {
                    week_forecast.append(DailyForecast(set_date: formatter.date(from: String(cString: sqlite3_column_text(select_forecast_statement, 2)))!, set_description: String(cString: sqlite3_column_text(select_forecast_statement, 3)), set_low_temp: Int(sqlite3_column_int(select_forecast_statement, 4)), set_high_temp: Int(sqlite3_column_int(select_forecast_statement, 5))))
                }
                sqlite3_finalize(select_full_forecast_statement)
            }
            else{
                week_forecast.append(DailyForecast(set_date: formatter.date(from: String(cString: sqlite3_column_text(select_forecast_statement, 2)))!, set_description: String(cString: sqlite3_column_text(select_forecast_statement, 3)), set_low_temp: Int(sqlite3_column_int(select_forecast_statement, 4)), set_high_temp: Int(sqlite3_column_int(select_forecast_statement, 5))))
            }
        }
        sqlite3_finalize(select_forecast_statement)
        
        return week_forecast
    }
    
    //  Load city by woeid
    public func load_city(by woeid: Int) -> City?{
        let select_city_query = "SELECT * from city WHERE woeid = \(woeid)"
        
        var select_city_statement: OpaquePointer? = nil
        
        let conn = SQLiteConnection.get_connection()
        
        sqlite3_prepare_v2(conn, select_city_query, -1, &select_city_statement, nil)
        
        var city: City? = nil
        
        if sqlite3_step(select_city_statement) == SQLITE_ROW{
            
            let woeid = Int(sqlite3_column_int(select_city_statement, 0))
            let name = String(cString: sqlite3_column_text(select_city_statement, 1))
            let region = String(cString: sqlite3_column_text(select_city_statement, 2))
            let country = String(cString: sqlite3_column_text(select_city_statement, 3))
            
            city = City(set_woeid: woeid, set_name: name, set_region: region, set_country: country, set_week_forecast: load_forecast(by: woeid))
        }
        sqlite3_finalize(select_city_statement)
        
        return city
    }
    
    //  Load array of cities
    public func load_cities() -> [City]{
        
        let select_city_query = "SELECT * from city"
        
        var select_city_statement: OpaquePointer? = nil
        
        let conn = SQLiteConnection.get_connection()
        
        sqlite3_prepare_v2(conn, select_city_query, -1, &select_city_statement, nil)
        
        var cities = [City]()
        
        while sqlite3_step(select_city_statement) == SQLITE_ROW{
            
            let woeid = Int(sqlite3_column_int(select_city_statement, 0))
            let name = String(cString: sqlite3_column_text(select_city_statement, 1))
            let region = String(cString: sqlite3_column_text(select_city_statement, 2))
            let country = String(cString: sqlite3_column_text(select_city_statement, 3))
            
            cities.append(City(set_woeid: woeid, set_name: name, set_region: region, set_country: country, set_week_forecast: load_forecast(by: woeid)))
        }
        
        sqlite3_finalize(select_city_statement)
        
        return cities
    }
}
