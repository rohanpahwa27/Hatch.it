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
    let overlay = UIView()
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func inviteFriends(_ sender: UIButton) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Create and share events with people around you! --> Download Hatch.it from the App Store: https://u3mt6.app.goo.gl/VunL"
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    @IBAction func inviteEmail(_ sender: UIButton) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setSubject("Hatch.it")
        composeVC.setMessageBody("Create and share events with people around you! --> Download Hatch.it from the App Store: https://u3mt6.app.goo.gl/VunL", isHTML: false)
        self.present(composeVC, animated: true, completion: nil)
    }
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        overlay.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let h = view.frame.height / 2 * 0.10
        let i = view.frame.height / 2 * 0.40
        let x = CGFloat(0.0)
        let y = view.frame.height - 30
        let p1 = CGPoint(x: x, y: y)
        let p2 = CGPoint(x:p1.x + view.frame.width, y:p1.y)
        let p3 = CGPoint(x:p2.x, y:p2.y - i)
        let p4 = CGPoint(x:p1.x, y:p2.y - h)
        let p5 = CGPoint(x:p1.x, y:p1.y)
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: p2)
        path.addLine(to: p3)
        path.addLine(to: p4)
        path.addLine(to: p5)
        path.close()
        let mask = CAShapeLayer()
        mask.frame = overlay.bounds
        mask.path = path.cgPath
        overlay.layer.mask = mask
        view.addSubview(overlay)
        view.sendSubview(toBack: overlay)
        let gradient = CAGradientLayer()
        gradient.frame = overlay.bounds
        gradient.colors = [
            UIColor(red: 198/255, green: 152/255, blue: 201/255, alpha: 1).cgColor, UIColor(red: 129/255, green: 151/255, blue: 229/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:0)
        self.overlay.layer.addSublayer(gradient)
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
