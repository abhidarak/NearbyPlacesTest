//
//  Common.swift
//
//  Created by Abhishek Darak
//

import UIKit


public class Common {
    
    public func createTables() -> Bool{
        do{
            try (SQLiteDBStore()).createTables()
            
            
        } catch  {
            return false
        }
        return true
    }
    
    public func deleteCacheData(table_name:NSString ) {
        (SQLiteDBStore()).deleteTables(table_name: table_name as String)
    }
    
    
    
    
    public static func getInt32Value(value:Any) -> Int32 {
        if value is String {
            let str_val:String = value as! String
            if str_val.isEmpty == true {
                return 0
            } else {
                return Int32(value as! String )!
            }
        }
        if value is Int {
            return Int32(value as! Int)
        }
        if value is Int32 {
            return value as! Int32
        }
        return 0
    }
    
    
    public static func getDoubleValue(value:Any) -> Double {
        if value is String {
            let str_val:String = value as! String
            if str_val.isEmpty == true {
                return 0.0
            } else {
                return Double(value as! String )!
            }
        }
        if value is Double {
            return Double(value as! Double)
        }
        return 0
    }
    
    public static func isNsnullOrNil(object : AnyObject?) -> Bool
    {
        if (object is NSNull) || (object == nil)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    
    public static func insertCachData() {
        
        let failureCallback = { (errorMessage: String) in
            print("User Venue Cache failed")
        }

        let unauthCallback = {
            print("User Venue Cache failed")
          
        }

        var is_venue_saved = (DataVenue()).is_venue_saved()
        
        if is_venue_saved == false {
            // Attempt to fetch the user's credentials using the entered login info
            /*
            RemoteApi.shared.getUseVenueV2(
                success: { (userVenue) in
                    (UserVenue()).bulkInsert(userVenue: userVenue)
                },
                failure: { (errorString) in
                    failureCallback(errorString)
                },
                unauthorized: {
                    unauthCallback()
                }
            )*/
        }
    }
}
