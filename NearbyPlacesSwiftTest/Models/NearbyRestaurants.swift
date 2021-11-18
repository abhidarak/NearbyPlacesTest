//
//  NearbyRestaurants.swift
//
//  Created by Abhishek Darak
//

import SwiftyJSON

class NearbyRestaurants: NSObject, NSCoding {
    
    @objc var venues: [VenueDetail]

    init(venue:[VenueDetail]) {
        venues = venue
    }
    
    /// Expects a JSON object with an 'attributes' top-level data key.
    init?(fromJson json: JSON) {

        guard let dataJsonArray = json["businesses"].array else {
            print("ChallengeLeaderboard.init(JSON): 'data' key not found in JSON or was not an array")
            return nil
        }
        
        //let cityName : String = json["location"]["city_name"].string!
        
        //UserDefaults.standard.set(cityName, forKey: "city") //setObject


        var venue_array = [VenueDetail]()
        var i = 0
        for venue_data in dataJsonArray
        {
            i = i + 1
            if let venue = VenueDetail(fromJson: venue_data) {
                venue_array.append(venue)
            }
            else
            {
                print("ChallengeLeaderboard.init(JSON): Failed to created ChallengeRank object from JSON")
                return nil
            }
           
        }
        venues = venue_array
    }
    
    
    // MARK: NSCoding
    // Implementing this protocol allows us to store this class in UserDefaults (we wrap with our LocalDefaults class)

    required init?(coder aDecoder: NSCoder) {
        venues = aDecoder.decodeObject(forKey: #keyPath(venues)) as! [VenueDetail]
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(venues, forKey: #keyPath(venues))
      
    }
    
    static func appendVenue(newVenue: VenueDetail, venueArray: [VenueDetail] ) -> [VenueDetail] {
        var result = venueArray
       
        if venueArray.firstIndex(where: {$0.venue_id == newVenue.venue_id}) != nil {
            return result
        } else {
            result.insert(newVenue, at: 0)
            return result
        }
    }
}

