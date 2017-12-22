//
//  TableViewCell.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 11/25/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventType: UILabel!
    @IBOutlet weak var filterCriteria: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
