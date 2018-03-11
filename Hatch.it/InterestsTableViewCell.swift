//
//  InterestsTableViewCell.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 2/4/18.
//  Copyright © 2018 Hatch Inc. All rights reserved.
//

import UIKit

class InterestsTableViewCell: UITableViewCell {

    @IBOutlet weak var interest: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
