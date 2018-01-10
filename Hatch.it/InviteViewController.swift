//
//  InviteViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 12/23/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit
import MessageUI

class InviteViewController: UIViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func inviteFriends(_ sender: UIButton) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Check out this app! --> Hatch.it"
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    @IBAction func inviteEmail(_ sender: UIButton) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setSubject("Hatch.it")
        composeVC.setMessageBody("Check out this app! --> Hatch.it", isHTML: false)
        self.present(composeVC, animated: true, completion: nil)
    }
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
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
