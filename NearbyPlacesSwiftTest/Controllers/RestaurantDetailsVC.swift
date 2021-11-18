//
//  RestaurantDetailsVC.swift
//
//  Created by Abhishek Darak
//

import UIKit
import SDWebImage

class RestaurantDetailsVC: UIViewController {
    
    @IBOutlet weak var venueDetailsScrollView : UIScrollView!
    
    var restaurantDetails: VenueDetail!
    
    var customView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.GCDTest()
        self.nsOperTest()
                
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomView", bundle: bundle)
        customView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        
        venueDetailsScrollView.addSubview(customView)
        
        venueDetailsScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)

        self.displayData()
        
    }
    
    func displayData () {
        
        /*
         101 - back button
         102 - title
         103 - image
         104 - venue name
         105, 106, 107 - rating
         108 - cuisines
         109 - address
         110 - cost for two
         */
                
        if let titleLbl = customView.viewWithTag(104) as? UILabel {
            titleLbl.text = restaurantDetails.venue_name
        }
        
        if let imgView = customView.viewWithTag(103) as? UIImageView {
            imgView.sd_setImage(with: URL(string:restaurantDetails.thumb), placeholderImage: nil , completed: {(image, error, cacheType, imageURL) in
            })
        }
        
        if let imgView = customView.viewWithTag(101) as? UIImageView {
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.backTapped(_:)))
            imgView.isUserInteractionEnabled = true;
            imgView.addGestureRecognizer(tap)
            
        }
        
        if let ratingLbl = customView.viewWithTag(106) as? UILabel {
            ratingLbl.text = restaurantDetails.aggregate_rating
        }
        
        if let ratingTxtLbl = customView.viewWithTag(107) as? UILabel {
            //ratingTxtLbl.text = restaurantDetails.rating_text
            //ratingTxtLbl.textColor = UIColor.fromHexString("#"+restaurantDetails.rating_color)
        }
        
        if let cuisinesLbl = customView.viewWithTag(108) as? UILabel {
            cuisinesLbl.text = restaurantDetails.cuisines
        }
        
        if let addresslbl = customView.viewWithTag(109) as? UILabel {
            addresslbl.text = restaurantDetails.address
        }
        
        if let costLbl = customView.viewWithTag(110) as? UILabel {
            costLbl.text = "Cost for two " + restaurantDetails.currency + restaurantDetails.cost_for_two+" approx"        }
                
        if let menulbl = customView.viewWithTag(111) as? UILabel {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.openMenu(_:)))
            menulbl.isUserInteractionEnabled = true;
            menulbl.addGestureRecognizer(tap)
        }
        
    }
    
    @objc func backTapped(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        
        
        dismiss(animated: true, completion: nil)

    }
    
    // open menu in browser
    @objc func openMenu(_ sender: UITapGestureRecognizer? = nil) {
        
        print("openMenu \(restaurantDetails.menu_url)")
        
        guard let url = URL(string: restaurantDetails.menu_url) else { return }
        UIApplication.shared.open(url)
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func GCDTest () {
        
        let delayInSeconds = 5.0
        
        print("here")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) { [weak self] in
          guard let self = self else {
            return
          }
            
            print("here2")

        }
        
        
    }
    
    func nsOperTest() {
        
        var queue = OperationQueue()
        
        queue.addOperation { () -> Void in
               
               print("here 3")
           }
           
        queue.addOperation { () -> Void in
               
            print("here 4")
           }
        
    }

}
