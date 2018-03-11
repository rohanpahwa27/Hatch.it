//
//  EventsHatchedTableViewCell.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 2/3/18.
//  Copyright © 2018 Hatch Inc. All rights reserved.
//

import UIKit

class EventsHatchedTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var peopleAttended: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        eventImage.clipsToBounds = true
        eventImage.layer.cornerRadius = eventImage.frame.height / 2
        eventImage.layer.borderWidth = 1
        eventImage.layer.borderColor = UIColor.init(red: 101/255, green: 98/255, blue: 190/255, alpha: 1).cgColor
        activityIndicator.startAnimating()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
