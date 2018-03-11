//
//  ViewViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 1/15/18.
//  Copyright © 2018 Hatch Inc. All rights reserved.
//

import UIKit

class ViewViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let pg = TrapezoidView(frame:CGRect(x: 0,y: 0, width: view.frame.width, height: 400))
        self.view.addSubview(pg)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
