//
//  DataVenue.swift
//
//  Created by Abhishek Darak
//
//
//  DataUserVenue.swift
//  iDailyhuman
//
//  Created by Team arroWebs on 27/07/20.
//  Copyright © 2020 Team arroWebs. All rights reserved.
//

import UIKit

class DataVenue: SQLiteDBStore {
    
    func is_venue_saved() -> Bool {
        
        let result = self.getResultByQuery(sql: "SELECT * FROM my_venue")
        if result.count > 1 {
            return true
        }
        return false
    }
    
    func get_venue_action(venue_id:String,action:Int) -> Int {
        var userAction = 0
        let result = self.getResultByQuery(sql: "SELECT * FROM my_venue where venue_id = '" +  venue_id + "' AND action = \(action) " )
        
        for venueAction in result {
            let row = venueAction as! [String:Any]
            userAction = Int(row["action"] as! String)!
        }
        return userAction
    }
    
    func delete_venue_action(venue_id:String)  {
        do {
            try self.executeQuery(sql: "DELETE FROM user_venue where venue_id = '" +  venue_id + "'")
        } catch {
            print("Error while deleted record")
        }
        
    }
}
