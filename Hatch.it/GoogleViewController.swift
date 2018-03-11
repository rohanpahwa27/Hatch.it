//
//  GoogleViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 12/21/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
class GoogleViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    let overlay = UIView()
    //Functions
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().currentUser?.link(with: credential)
        { (user, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: "Google Account Already Linked", preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title: "Success", message: "Google Account Linked", preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    //IBActions
    @IBAction func linkGoogleAccount(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    @IBAction func unlinkGoogleAccount(_ sender: UIButton) {
        Auth.auth().currentUser?.unlink(fromProvider: "google.com") { (user, error) in
            if error == nil {
                let alert = UIAlertController(title: "Success", message: "Google Account Unlinked", preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                GIDSignIn.sharedInstance().signOut()
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title: "Error", message: "Google Account Not Linked", preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    //Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
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
