//
//  EventCreatedViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 11/28/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
class EventCreatedViewController: UIViewController {

    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventLocation: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        eventImage.layer.cornerRadius = 10
    }

    override func viewDidAppear(_ animated: Bool) {
        self.eventName.text! = globalVariables.event.eventName!
        self.eventLocation.text! = globalVariables.event.location!
        self.eventDate.text! = globalVariables.event.eventDate!
        self.eventDescription.text! = globalVariables.event.eventDescription!
        /*let url = URL(string: globalVariables.event.eventImage!)
        URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
            if(error == nil)
            {
                DispatchQueue.main.async {
                    self.eventImage.image = UIImage(data: data!)
            }
            }
        }).resume()*/
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
