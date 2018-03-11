//
//  GoogleViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 12/21/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
class FacebookViewController: UIViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var facebookImage: UIImageView!
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().currentUser?.link(with: credential)
        { (user, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: "Facebook Account Already Linked", preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title: "Success", message: "Facebook Account Linked", preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        Auth.auth().currentUser?.unlink(fromProvider: "facebook.com") { (user, error) in
            if error == nil {
                let alert = UIAlertController(title: "Success", message: "Facebook Account Unlinked", preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title: "Error", message: "Facebook Account Not Linked", preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    let overlay = UIView()
    //Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        let facebookButtons = FBSDKLoginButton()
        let x1 = view.center.x
        let y1 = facebookImage.center.y + 70
        facebookButtons.center = CGPoint(x: x1, y: y1)
        let buttonText = NSAttributedString(string: "Link/Unlink Account")
        facebookButtons.setAttributedTitle(buttonText, for: .normal)
        view.addSubview(facebookButtons)
        facebookButtons.delegate = self
        overlay.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let h = view.frame.height / 2 * 0.10
        let i = view.frame.height / 2 * 0.40
        let x = CGFloat(0.0)
        let y = view.frame.height - 30
        let p1 = CGPoint(x: x, y: y)
        let p2 = CGPoint(x:p1.x + view.frame.width, y:p1.y)
        let p3 = CGPoint(x:p2.x, y:p2.y - i)
        let p4 = CGPoint(x:p1.x, y:p2.y - h)
        let p5 = CGPoint(x:p1.x, y:p1.y)
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: p2)
        path.addLine(to: p3)
        path.addLine(to: p4)
        path.addLine(to: p5)
        path.close()
        let mask = CAShapeLayer()
        mask.frame = overlay.bounds
        mask.path = path.cgPath
        overlay.layer.mask = mask
        view.addSubview(overlay)
        view.sendSubview(toBack: overlay)
        let gradient = CAGradientLayer()
        gradient.frame = overlay.bounds
        gradient.colors = [
            UIColor(red: 198/255, green: 152/255, blue: 201/255, alpha: 1).cgColor, UIColor(red: 129/255, green: 151/255, blue: 229/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:0)
        self.overlay.layer.addSublayer(gradient)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

