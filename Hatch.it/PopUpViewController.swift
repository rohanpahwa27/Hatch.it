//
//  PopUpViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 11/25/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
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
    @IBAction func distanceFurthest(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callForAlert7"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func spotsRemaining(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callForAlert4"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func publicEvents(_ sender: UIButton) {
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callForAlert"), object: nil)
         dismiss(animated: true, completion: nil)
    }
    @IBAction func privateEvents(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callForAlert2"), object: nil)
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
