//
//  ViewController.swift
//
//  Created by Abhishek Darak
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    var lat, lon : String!
    var restaurantsArray : NSArray!
    
    var nearbyRestaurants: [VenueDetail] = []
    
    var venueDetail = VenueDetail()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager = CLLocationManager()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.get_user_location()

    }
    
    func get_nearby_restaurants() {
        
        let failureCallback = { (errorMessage: String) in
            print(" failed")
        }

        let unauthCallback = {
            print("failed")
        }
        
        RemoteApi.shared.getDataFromYelpAPI(lat: lat, lon: lon, term:"",
            success: {
                (myResult) in
                
                self.nearbyRestaurants = myResult.venues
                                
                self.redirect_to_restaurant_list()
               
            },
            failure: { (errorString) in
                failureCallback(errorString)
            },
            unauthorized: {
                unauthCallback()
            }
        )
        
    }
    
    func redirect_to_restaurant_list () {
        
        print("redirect_to_restaurant_list")
        
        let restaurantList = NearbyRestaurantsVC()
        
        restaurantList.modalPresentationStyle = .fullScreen
        
        restaurantList.restaurantsArray = nearbyRestaurants

        
        self.present(restaurantList, animated:true, completion:nil)

/*
self.navigationController?.pushViewController(restaurantList, animated: true)
        */
        
    }
    
    func get_user_location() {
        
        locationManager.requestWhenInUseAuthorization()
        
            /*
        var currentLoc: CLLocation!
        
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
        CLLocationManager.authorizationStatus() == .authorizedAlways) {
           currentLoc = locationManager.location
           print(currentLoc)
           print(currentLoc.coordinate.longitude)
        }*/
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        
    }
    
        //MARK: - location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation

        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        lat = String(format: "%f", userLocation.coordinate.latitude)
        lon = String(format: "%f", userLocation.coordinate.longitude)
        
        self.get_nearby_restaurants()

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
        
        // set default lat lon for testing
        lat = String(format: "%f", 24)
        lon = String(format: "%f", 73)
        
        self.get_nearby_restaurants()
        
    }


}

