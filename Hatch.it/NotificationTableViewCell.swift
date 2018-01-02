//
//  NotificationTableViewCell.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 12/23/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit
class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var notificationTitle: UILabel!
    @IBOutlet weak var notificationBody: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        notificationBody.textContainer.lineFragmentPadding = 0
        notificationImage.layer.borderColor = UIColor.white.cgColor
        notificationImage.layer.borderWidth = 3
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    }

