//
//  UsersTableViewCell.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 1/12/18.
//  Copyright © 2018 Hatch Inc. All rights reserved.
//

import UIKit

class UsersTableViewCell: UITableViewCell {
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    
    let gradientOne = UIColor(red: 69/255, green: 104/255, blue: 220/255, alpha: 1).cgColor
    let gradientTwo = UIColor(red: 176/255, green: 106/255, blue: 179/255, alpha: 1).cgColor
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        loader.startAnimating()
        gradientSet.append([gradientOne, gradientTwo])
        gradientSet.append([gradientTwo, gradientTwo])
        gradient.frame = borderView.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        gradient.drawsAsynchronously = true
        borderView.layer.addSublayer(gradient)
        animateGradient()
        borderView.clipsToBounds = true
        borderView.layer.cornerRadius = borderView.frame.height / 2
        profilePicture.clipsToBounds = true
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
    }
    func animateGradient() {
        if currentGradient < gradientSet.count - 1 {
            currentGradient += 1
        } else {
            currentGradient = 0
        }
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.repeatCount = Float.infinity
        gradientChangeAnimation.autoreverses = true
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradientChangeAnimation.duration = 2.0
        gradientChangeAnimation.toValue = gradientSet[currentGradient]
        gradientChangeAnimation.fillMode = kCAFillModeForwards
        gradient.add(gradientChangeAnimation, forKey: "colorChange")
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
