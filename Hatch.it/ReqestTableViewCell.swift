//
//  ReqestTableViewCell.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 1/12/18.
//  Copyright © 2018 Hatch Inc. All rights reserved.
//

import UIKit

class ReqestTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var decision: UILabel!
    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var approveButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderColor = UIColor(red: 176/255, green: 106/255, blue: 179/255, alpha: 1).cgColor
        profilePicture.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
