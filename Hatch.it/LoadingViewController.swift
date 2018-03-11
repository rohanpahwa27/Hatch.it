//
//  LoadingViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 1/31/18.
//  Copyright © 2018 Hatch Inc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
class LoadingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 75, height: 75), type: .lineScalePulseOut, color: UIColor.black)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.dismiss(animated: true, completion: nil)
        })
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
