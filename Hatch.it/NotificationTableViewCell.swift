//
//  NotificationTableViewCell.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 12/23/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit
class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var notificationTitle: UILabel!
    @IBOutlet weak var notificationBody: UILabel!
    @IBOutlet weak var notificationTime: UILabel!
    @IBOutlet weak var requestedTitle: UILabel!
    @IBOutlet weak var statement: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        notificationImage.layer.cornerRadius = notificationImage.frame.height / 2
        notificationImage.clipsToBounds = true
        notificationImage.layer.borderColor = UIColor(red: 176/255, green: 106/255, blue: 179/255, alpha: 1).cgColor
        notificationImage.layer.borderWidth = 1
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    }

