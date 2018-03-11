//
//  TabBarViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 12/8/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//

import UIKit
class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        if(values.link){
            selectedIndex = 1
        }
        else{
            selectedIndex = 2
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
