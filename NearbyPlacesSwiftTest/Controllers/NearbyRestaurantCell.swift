//
//  NearbyRestaurantCell.swift
//
//  Created by Abhishek Darak
//

import UIKit

class NearbyRestaurantCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl : UILabel!
    @IBOutlet weak var detailLbl : UILabel!
    @IBOutlet weak var costLbl : UILabel!
    @IBOutlet weak var venueImg : UIImageView!
    @IBOutlet weak var containerView : UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
