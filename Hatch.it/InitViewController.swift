//
//  InitViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 10/14/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//

import UIKit
import Firebase
class InitViewController: UIViewController {
    //Override Functions
    override func viewDidAppear(_ animated: Bool) {
        if(Auth.auth().currentUser != nil){
            self.performSegue(withIdentifier: "currentUser", sender: self)
        }
        else{
            self.performSegue(withIdentifier: "noCurrentUser", sender: self)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
