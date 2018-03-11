//
//  SettingsTableViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 11/24/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
class SettingsTableViewController: UITableViewController {
    //IBActions
    @IBAction func signOut(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signOut()
        FBSDKLoginManager().logOut()
    }
    @IBAction func logOut(_ sender: UIButton) {
        FBSDKLoginManager().logOut()
        do{
            try Auth.auth().signOut()
        } catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    //Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
