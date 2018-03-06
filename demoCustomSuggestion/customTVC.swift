//
//  customTVC.swift
//  demoCustomSuggestion
//
//  Created by Atal Bansal on 06/09/16.
//  Copyright © 2016 Atal Bansal. All rights reserved.
//

import UIKit

class customTVC: UITableViewCell {
	static let cellIDentifier:String = "customTVC"
	@IBOutlet  weak var btn:UIButton!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
