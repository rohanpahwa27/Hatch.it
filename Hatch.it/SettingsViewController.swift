//
//  SettingsViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 9/20/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
class SettingsViewController: UIViewController {

    //IBActions
    @IBAction func logOutUser(_ sender: UIButton) {
        if(Auth.auth().currentUser != nil)
        {
            do{
                try Auth.auth().signOut()
            } catch let error as NSError
            {
                print(error.localizedDescription)
            }
        }
    }
    //Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        

        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
