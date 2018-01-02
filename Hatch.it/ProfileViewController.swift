//
//  ProfileViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 12/4/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
class ProfileViewController: UIViewController {

    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var selectedFirstName: UILabel!
    @IBOutlet weak var selectedLastName: UILabel!
    @IBOutlet weak var selectedUsername: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
            
            for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                if(eventID.key == user.userID)
                {
                    for child in eventID.children.allObjects as! [DataSnapshot] {
                        if(child.key == "First Name")
                        {
                            self.selectedFirstName.text = child.value as? String
                        }
                        if(child.key == "Last Name")
                        {
                            self.selectedLastName.text = child.value as? String
                        }
                        if(child.key == "Username")
                        {
                            self.selectedUsername.text = child.value as? String
                        }
                    }
                    
                }
                
            }
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
