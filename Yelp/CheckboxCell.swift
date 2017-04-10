//
//  CheckboxCell.swift
//  Yelp
//
//  Created by Kim Toy (Personal) on 4/8/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class CheckboxCell: UITableViewCell {

    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var emptyCheckboxImageView: UIImageView!
    @IBOutlet weak var checkboxLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkboxImageView.alpha = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
