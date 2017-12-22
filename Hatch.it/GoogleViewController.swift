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
        view.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 49/255, alpha: 1)
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
