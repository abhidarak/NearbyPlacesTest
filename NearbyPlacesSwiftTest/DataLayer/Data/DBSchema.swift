//
//  DBSchema.swift
//
//  Created by Abhishek Darak
//

import UIKit

class DBSchema: NSObject {
    
    static let TablesName:[String] = [
        "my_venue",
        "user_profile"
    ]
    
    static let MyVenue:String = "my_venue"
    static let MyVenueColumns: [Int32:String]  = [
        0:"id",
        1:"venue_id",
        2:"venue_name",
        3:"venue_category",
        4:"venue_address",
        5:"venue_image",
        6:"action"
    ]
     
    static let MyVenueColumnsType: [String:String]  = [
        "id":"TEXT",
        "venue_id":"TEXT",
        "venue_name":"TEXT",
        "venue_category":"TEXT",
        "venue_address":"TEXT",
        "venue_image":"TEXT",
        "action": "INTEGER"
    ]
    
    static let UserProfileName:String = "user_profile"
    static let UserProfileColumns: [Int32:String]  = [
        0:"user_id",
        1:"name"
    ]
     
    static let UserProfileColumnsType: [String:String]  = [
        "user_id":"TEXT",
        "name": "TEXT"
    ]
    
}
