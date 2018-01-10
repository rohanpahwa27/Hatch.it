//
//  PopUpViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 11/25/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
class PopUpViewController: UIViewController {
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var upIcon: UIImageView!
    @IBOutlet weak var downIcon: UIImageView!
    @IBOutlet weak var spotsRemaining2: UIButton!
    @IBOutlet weak var spotsRemaining: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if globalEvent.up == false{
            downIcon.alpha = 0
            upIcon.alpha = 1
            spotsRemaining.alpha = 1
            spotsRemaining2.alpha = 0
        }
        else{
            downIcon.alpha = 1
            upIcon.alpha = 0
            spotsRemaining.alpha = 0
            spotsRemaining2.alpha = 1
        }
        popUpView.layer.cornerRadius = 10
        popUpView.layer.masksToBounds = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func defaultSort(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callForAlert3"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func distanceClosest(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callForAlert6"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func spotsRemaining(_ sender: UIButton) {
        globalEvent.up = true
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callForAlert4"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func spotsRemaining2(_ sender: UIButton) {
        globalEvent.up = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callForAlert1"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func date(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callForAlert5"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    func dismissView() {
        dismiss(animated: true, completion: nil)
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
