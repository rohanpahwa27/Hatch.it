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
                    print(error!)
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
        view.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
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
        let myColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        userEmail.layer.borderWidth = 1
        userEmail.layer.borderColor = myColor.cgColor
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
            userEmail.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            userEmail.textColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        }
        else{
            userEmail.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        userEmail.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        userEmail.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
    }
}
