//
//  InitViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 10/14/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//

import UIKit
import Firebase
class InitViewController: UIViewController, CAAnimationDelegate {
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var launchLogo: UIImageView!
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    
    let gradientOne = UIColor(red: 139/255, green: 34/255, blue: 34/255, alpha: 1).cgColor
    let gradientThree = UIColor(red: 225/255, green: 201/255, blue: 222/255, alpha: 1).cgColor
    let gradientTwo = UIColor(red: 239/255, green: 59/255, blue: 51/255, alpha: 1).cgColor
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
       // gradientChangeAnimation.isRemovedOnCompletion = false
        gradient.add(gradientChangeAnimation, forKey: "colorChange")
        
    }
    //Override Functions
    override func viewDidAppear(_ animated: Bool) {
        
        launchLogo.layer.borderWidth = 3
        launchLogo.layer.borderColor = UIColor(red: 48/255, green: 55/255, blue: 59/255, alpha: 1).cgColor
        gradientSet.append([gradientOne, gradientTwo])
        gradientSet.append([gradientTwo, gradientThree])
        gradientSet.append([gradientThree, gradientOne])
        gradient.frame = borderView.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        gradient.drawsAsynchronously = true
        borderView.layer.addSublayer(gradient)
        animateGradient()
        let when = DispatchTime.now() + 3 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            if(Auth.auth().currentUser != nil){
                self.performSegue(withIdentifier: "currentUser", sender: self)
            }
            else{
               self.performSegue(withIdentifier: "noCurrentUser", sender: self)
            }
        }

        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
