//
//  CreateAccount2ViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 10/16/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit

class CreateAccount2ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userBirthday: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var createPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBAction func createAccount(_ sender: UIButton) {
        if(userBirthday.text! == "" || userName.text! == "" || createPassword.text! == "" || confirmPassword.text! == "")
        {
            let alert = UIAlertController(title: "Error", message: "Fields Cannot be Left Blank", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userBirthday.delegate = self
        self.userName.delegate = self
        self.createPassword.delegate = self
        self.confirmPassword.delegate = self
        view.backgroundColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        let myColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        userBirthday.layer.borderWidth = 1
        userName.layer.borderWidth = 1
        createPassword.layer.borderWidth = 1
        confirmPassword.layer.borderWidth = 1
        userBirthday.layer.borderColor = myColor.cgColor
        userName.layer.borderColor = myColor.cgColor
        createPassword.layer.borderColor = myColor.cgColor
        confirmPassword.layer.borderColor = myColor.cgColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if(userBirthday.isEditing)
        {
            userBirthday.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            userBirthday.textColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        else
        {
            userBirthday.backgroundColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        if(userName.isEditing)
        {
            userName.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            userName.textColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        else
        {
            userName.backgroundColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        if(createPassword.isEditing)
        {
            createPassword.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            createPassword.textColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        else
        {
            createPassword.backgroundColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        if(confirmPassword.isEditing)
        {
            confirmPassword.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            confirmPassword.textColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        else
        {
            confirmPassword.backgroundColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        userBirthday.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        userName.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        userName.backgroundColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        userBirthday.backgroundColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
         createPassword.backgroundColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
         confirmPassword.backgroundColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        createPassword.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        confirmPassword.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        
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
