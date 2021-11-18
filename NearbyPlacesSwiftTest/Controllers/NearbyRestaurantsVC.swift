//
//  NearbyRestaurantsVC.swift
//
//  Created by Abhishek Darak
//

import UIKit
import SDWebImage
import SVProgressHUD

class NearbyRestaurantsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate  {
    
    var restaurantsArray : [VenueDetail] = []
    
    @IBOutlet weak var nearbyRestaurantsTable : UITableView!
    
    @IBOutlet weak var cityLbl : UILabel!
    
    var isFirstLoad = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isFirstLoad = true
        
        let citytap = UITapGestureRecognizer(target: self, action: #selector(self.chageCityTapped(_:)))
        cityLbl.isUserInteractionEnabled = true;
        cityLbl.addGestureRecognizer(citytap)
        cityLbl.text = "Search by location or food"

        // Do any additional setup after loading the view.

        //nearbyRestaurantsTable.register(NearbyRestaurantCell.self, forCellReuseIdentifier: "NearbyRestaurantCell")
        
        nearbyRestaurantsTable.automaticallyAdjustsScrollIndicatorInsets = false
        
        nearbyRestaurantsTable.showsHorizontalScrollIndicator = false
        nearbyRestaurantsTable.showsVerticalScrollIndicator = false
        
        if(restaurantsArray.count > 0) {
            
            (SQLiteDBStore()).deleteTables(table_name: "my_venue")
            
            for VenueDetail in restaurantsArray {
                
                var venueData = [String: String]()
                
                venueData["id"] = VenueDetail.venue_id
                venueData["venue_id"] = VenueDetail.venue_id
                venueData["venue_name"] = VenueDetail.venue_name
                
                (SQLiteDBStore()).save(table_name: "my_venue", data: venueData, update_field: "")
                
                //(CoreDataDBStore()).saveVenue(myData: venueData)
            }
        }
        
        let myCachedData = (SQLiteDBStore()).getResultByQuery(sql: "SELECT * FROM my_venue")
        
        print("my data - \(myCachedData.count)")
        
        
        
        /*
        let myCachedData2 = (CoreDataDBStore()).getVenues()
                
        print("core data - \(myCachedData2)")
        
        for eachData in myCachedData2 {
            
            print("data - \(eachData)")
            
        }*/
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstLoad {
            
            isFirstLoad = false
            nearbyRestaurantsTable.automaticallyAdjustsScrollIndicatorInsets = false
            
            nearbyRestaurantsTable.showsHorizontalScrollIndicator = false
            nearbyRestaurantsTable.showsVerticalScrollIndicator = false
            
            print("nearby restaurant load - \(restaurantsArray)")

            nearbyRestaurantsTable.reloadData()
            
            //cityLbl.text = UserDefaults.standard.string(forKey: "city")
                        
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("count - \(restaurantsArray.count)")
        
        return restaurantsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*
        let cell: NearbyRestaurantCell = tableView.dequeueReusableCell(withIdentifier: "NearbyRestaurantCell", for: indexPath) as! NearbyRestaurantCell*/
        
        let identifier = "NearbyRestaurantCell"

        var cell: NearbyRestaurantCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? NearbyRestaurantCell

          if cell == nil {
            tableView.register(UINib(nibName: "NearbyRestaurantCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? NearbyRestaurantCell
            }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none


        let venueDetail : VenueDetail = restaurantsArray[indexPath.row]
        
        print("name - \(venueDetail)")
        
        // set the text from the data model
        cell.titleLbl?.text = venueDetail.venue_name
        cell.detailLbl?.text = venueDetail.address
        cell.costLbl?.text = venueDetail.currency
        
        cell.venueImg.sd_setImage(with: URL(string:venueDetail.thumb), placeholderImage: nil , completed: {(image, error, cacheType, imageURL) in
        })
        
        cell.contentView.dropCellShadow(color: UIColor.fromHexString("#cccccc"), opacity: 0.1, offSet: CGSize.zero, radius: 2, scale: true)

        
        return cell
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 125.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt
    indexPath: IndexPath){

        let venueDetail : VenueDetail = restaurantsArray[indexPath.row]
        
        let detailVC = RestaurantDetailsVC()
        
        detailVC.modalPresentationStyle = .fullScreen
        
        detailVC.restaurantDetails = venueDetail

        
        self.present(detailVC, animated:true, completion:nil)
        
    }
    
    @objc func chageCityTapped(_ sender: UITapGestureRecognizer? = nil) {
        
        let alert = UIAlertController(title: "Filter", message: "Please Select location, food or restaurant", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "New York", style: .default , handler:{ (UIAlertAction)in
            print("User click Mumbai button")
            self.setLocation(location: "New York", term: "")
        }))
        
        alert.addAction(UIAlertAction(title: "Los Angeles", style: .default , handler:{ (UIAlertAction)in
            print("User click Delhi button")
            self.setLocation(location: "Los Angeles", term: "")
        }))
        
        alert.addAction(UIAlertAction(title: "Chicago ", style: .default , handler:{ (UIAlertAction)in
            print("User click Delhi button")
            self.setLocation(location: "Chicago", term: "")
        }))

        alert.addAction(UIAlertAction(title: "Restaurants at New York", style: .default , handler:{ (UIAlertAction)in
            self.setLocation(location: "New York", term: "Restaurant")
        }))
        
        alert.addAction(UIAlertAction(title: "Startbucks at New York", style: .default , handler:{ (UIAlertAction)in
            self.setLocation(location: "New York", term: "Startbuck")
        }))
        
        alert.addAction(UIAlertAction(title: "Burgers at New York", style: .default , handler:{ (UIAlertAction)in
            self.setLocation(location: "New York", term: "Burger")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Cancel button")
        }))

        
        //uncomment for iPad Support
        //alert.popoverPresentationController?.sourceView = self.view

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
    }
    
    func setLocation (location: String, term: String) {
        
        var locations = [String: Any]()
        
        locations["New York"] = ["lat": "40.71", "lon": "-74.00"]
        locations["Los Angeles"] = ["lat": "33.93", "lon": "-118.40"]
        locations["Chicago"] = ["lat": "41.90", "lon": "87.65"]
                
        if let selectedLocation = locations[location] as? [String: String] {
            let lat = selectedLocation["lat"]!
            let lon = selectedLocation["lon"]!
            
            self.loadData(newlat: lat, newlon: lon, term: term)
        }
        
    }
    
    func loadData (newlat: String, newlon: String, term: String) {
        
        let failureCallback = { (errorMessage: String) in
            print(" failed")
        }

        let unauthCallback = {
            print("failed")
        }
        
        SVProgressHUD.show()
        
        RemoteApi.shared.getDataFromYelpAPI(lat: newlat, lon: newlon, term: term,
            success: {
                (myResult) in
                
                SVProgressHUD.dismiss()
                
                self.restaurantsArray = myResult.venues
                                
                self.nearbyRestaurantsTable.reloadData()
               
            },
            failure: { (errorString) in
                failureCallback(errorString)
                SVProgressHUD.dismiss()
            },
            unauthorized: {
                unauthCallback()
                SVProgressHUD.dismiss()
            }
        )
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
