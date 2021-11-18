//
//  VenueDetail.swift
//
//  Created by Abhishek Darak
//

import SwiftyJSON

class VenueDetail: NSObject, NSCoding {
    
        @objc let venue_name: String
        @objc let venue_id: String
        
    @objc var address: String
    
    @objc var featured_image: String
    @objc var thumb: String
    @objc var cuisines: String
    @objc var cost_for_two: String
   
    @objc var currency: String
    @objc var menu_url: String
    @objc var aggregate_rating: String
    @objc var lat: String
    @objc var lon: String
    
    override init() {
        venue_name = ""
        venue_id = ""
        address = ""
        
        featured_image = ""
        thumb = ""
        cuisines = ""
        cost_for_two = ""
        
        currency = ""
        menu_url = ""
        aggregate_rating = ""
        lat = ""
        lon = ""
                        
        }
        
        /// Expects a JSON object with an 'attributes' top-level data key.
        init?(fromJson json: JSON) {
            
            /*
            guard json["restaurant"].exists() else {
                print("nearby_restaurants.init(JSON): 'restaurant' key not found in JSON")
                return nil
            }*/
            
          /*  guard let dataJsonArray = json["data"]["item_details"]["timeline"].array else {
                print("VenueDetail.init(JSON): 'timeline' key not found in JSON or was not an array")
                return nil
            }
            */
            let attributes = json // json["restaurant"]
            
            venue_name = attributes["name"].stringValue
            venue_id = attributes["id"].stringValue
            address = attributes["location"]["address1"].stringValue+", "+attributes["location"]["city"].stringValue
            
            featured_image = attributes["image_url"].stringValue
            thumb = attributes["image_url"].stringValue
            cuisines = attributes["display_phone"].stringValue
                cost_for_two = attributes["price"].stringValue
               
                currency = attributes["price"].stringValue
                menu_url = attributes["url"].stringValue
            aggregate_rating = attributes["rating"].stringValue
                lat = attributes["coordinates"]["latitude"].stringValue
                lon = attributes["coordinates"]["longitude"].stringValue
            
        }
        
        
        // MARK: NSCoding
        // Implementing this protocol allows us to store this class in UserDefaults (we wrap with our LocalDefaults class)
        
        required init?(coder aDecoder: NSCoder) {
            
            venue_name = aDecoder.decodeObject(forKey: #keyPath(venue_name)) as! String
            venue_id = aDecoder.decodeObject(forKey: #keyPath(venue_id)) as! String
            address = aDecoder.decodeObject(forKey: #keyPath(address)) as! String
            

            featured_image = aDecoder.decodeObject(forKey: #keyPath(featured_image)) as! String
            thumb = aDecoder.decodeObject(forKey: #keyPath(thumb)) as! String
            aggregate_rating = aDecoder.decodeObject(forKey: #keyPath(aggregate_rating)) as! String
            menu_url = aDecoder.decodeObject(forKey: #keyPath(menu_url)) as! String
            currency = aDecoder.decodeObject(forKey: #keyPath(currency)) as! String
            cost_for_two = aDecoder.decodeObject(forKey: #keyPath(cost_for_two)) as! String
            cuisines = aDecoder.decodeObject(forKey: #keyPath(cuisines)) as! String
            lat = aDecoder.decodeObject(forKey: #keyPath(lat)) as! String
            lon = aDecoder.decodeObject(forKey: #keyPath(lon)) as! String
            
            super.init()
        }
        
        func encode(with aCoder: NSCoder) {
            
            aCoder.encode(venue_name, forKey: #keyPath(venue_name))
            aCoder.encode(venue_id, forKey: #keyPath(venue_id))
            aCoder.encode(address, forKey: #keyPath(address))
            
            aCoder.encode(thumb, forKey: #keyPath(thumb))
            
        }
    }
