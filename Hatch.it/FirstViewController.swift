//
//  FirstViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 9/18/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
class FirstViewController: UIViewController {
    
    
    
    @IBOutlet weak var logInText: UIButton!
    @IBAction func logInPressed(_ sender: UIButton) {
        //
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: ((view.frame.width)/2)-300/2, y: logInText.frame.origin.y + 50, width: 300, height: 500)
        view.addSubview(googleButton)
        
        
    
        
        
        
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
