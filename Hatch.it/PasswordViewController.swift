//
//  PasswordViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 10/30/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//

import UIKit
import Firebase
class PasswordViewController: UIViewController, UITextFieldDelegate {
    
    //IBOutlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var userEmail: UITextField!
    //IBActions
    @IBAction func passwordReset(_ sender: UIButton) {
        if(userEmail.text! == ""){
            let alert = UIAlertController(title: "Error", message: "Fields Cannot Be Left Blank", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else if(!userEmail.text!.contains("@")){
            let alert = UIAlertController(title: "Error", message: "Please Enter A Valid Email", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else{
            Auth.auth().fetchProviders(forEmail: userEmail.text!, completion: { (stringArray, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: "Network Error", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    if stringArray == nil {
                        let alert = UIAlertController(title: "Error", message: "Your Account Does Not Exist", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        Auth.auth().sendPasswordReset(withEmail: self.userEmail.text!, completion: nil)
                        let alert = UIAlertController(title: "Success", message: "Password Change Request Sent", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        }
    }
    //Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(red: 69/255, green: 104/255, blue: 220/255, alpha: 1)
        backgroundView.frame = view.frame
        let gradient = CAGradientLayer()
        gradient.frame = backgroundView.bounds
        gradient.colors = [
            UIColor(red: 69/255, green: 104/255, blue: 220/255, alpha: 1).cgColor,
            UIColor(red: 176/255, green: 106/255, blue: 179/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x:0.5, y:0)
        gradient.endPoint = CGPoint(x:0.5, y:1)
        self.backgroundView.layer.addSublayer(gradient)
        self.userEmail.delegate = self
        configureEmail()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //Functions
    func configureEmail() {
        userEmail.layer.borderWidth = 1
        userEmail.layer.borderColor = UIColor.white.cgColor
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(userEmail.isEditing){
            userEmail.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
            userEmail.textColor = UIColor.black
        }
        else{
            userEmail.backgroundColor = UIColor.clear
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        userEmail.textColor = UIColor.white
        userEmail.backgroundColor = UIColor.clear
    }
}
