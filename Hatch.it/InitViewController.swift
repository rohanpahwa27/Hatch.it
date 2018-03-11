//
//  InitViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 10/14/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView
class InitViewController: UIViewController, CAAnimationDelegate {
    
    //Override Functions
    override func viewDidAppear(_ animated: Bool) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor(red: 69/255, green: 104/255, blue: 220/255, alpha: 1).cgColor,
            UIColor(red: 176/255, green: 106/255, blue: 179/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x:0.5, y:0)
        gradient.endPoint = CGPoint(x:0.5, y:1)
        self.view.layer.addSublayer(gradient)
        let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 75, height: 75), type: .circleStrokeSpin, color: UIColor.white)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        let when = DispatchTime.now() + 3 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            /*
             let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
                if(snapshot.key == uid!){
                    self.performSegue(withIdentifier: "currentUser", sender: self)
                }
            })
               self.performSegue(withIdentifier: "noCurrentUser", sender: self)
 */
            
            if(Auth.auth().currentUser == nil){
                self.performSegue(withIdentifier: "noCurrentUser", sender: self)
            }
            else{
                self.performSegue(withIdentifier: "currentUser", sender: self)
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
