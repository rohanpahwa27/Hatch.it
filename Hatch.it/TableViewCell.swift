//
//  TableViewCell.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 11/25/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var circleOne: UIImageView!
    @IBOutlet weak var circleTwo: UIImageView!
    @IBOutlet weak var circleThree: UIImageView!
    @IBOutlet weak var circleFour: UIImageView!
    @IBOutlet weak var circleFive: UIImageView!
    @IBOutlet weak var circleSix: UIImageView!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDay: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var eventMonth: UILabel!
    @IBOutlet weak var privacyImage: UIImageView!
    @IBOutlet weak var circleOneUser: UILabel!
    @IBOutlet weak var circleTwoUser: UILabel!
    @IBOutlet weak var circleThreeUser: UILabel!
    @IBOutlet weak var circleFourUser: UILabel!
    @IBOutlet weak var circleFiveUser: UILabel!
    @IBOutlet weak var circleSixUser: UILabel!
    @IBOutlet weak var imageLoader: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageLoader.hidesWhenStopped = true
        imageLoader.center = eventImage.center
        imageLoader.startAnimating()
        circleOne.layer.cornerRadius = circleOne.frame.height/2
        circleTwo.layer.cornerRadius = circleTwo.frame.height/2
        circleThree.layer.cornerRadius = circleThree.frame.height/2
        circleFour.layer.cornerRadius = circleFour.frame.height/2
        circleFive.layer.cornerRadius = circleFive.frame.height/2
        circleSix.layer.cornerRadius = circleSix.frame.height/2
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
