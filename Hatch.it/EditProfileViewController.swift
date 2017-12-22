//
//  EditProfileViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 11/1/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
class EditProfileViewController: UIViewController, UITextFieldDelegate {
    //Variables and Constants
    let datePicker = UIDatePicker()
    let ref = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    //IBOutlets
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var birthDay: UITextField!
    //IBActions
    @IBAction func saveChanges(_ sender: UIButton) {
        ref.child("Users").child(uid!).updateChildValues(["First Name": firstName.text! as Any])
        ref.child("Users").child(uid!).updateChildValues(["Last Name": lastName.text! as Any])
        ref.child("Users").child(uid!).updateChildValues(["Username": userName.text! as Any])
        ref.child("Users").child(uid!).updateChildValues(["Birthday": birthDay.text! as Any])
        let alert = UIAlertController(title: "Success", message: "Profile Updated", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    //Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        configureScheme()
        configureDatePicker()
        displayInfo()
        self.firstName.delegate = self
        self.lastName.delegate = self
        self.userName.delegate = self
        self.birthDay.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //Functions
    func displayInfo()
    {
        ref.child("Users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot)
            in
            if let dict = snapshot.value as? [String: AnyObject]
            {
                self.firstName.text! = dict["First Name"] as! String
                self.lastName.text! = dict["Last Name"] as! String
                self.userName.text! = dict["Username"] as! String
                self.birthDay.text! = dict["Birthday"] as! String
            }
        })
    }
    func configureScheme() {
        firstName.layer.borderWidth = 1
        lastName.layer.borderWidth = 1
        userName.layer.borderWidth = 1
        birthDay.layer.borderWidth = 1
        let color = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        firstName.layer.borderColor = color.cgColor
        lastName.layer.borderColor = color.cgColor
        userName.layer.borderColor = color.cgColor
        birthDay.layer.borderColor = color.cgColor
        firstName.textColor = color
        lastName.textColor = color
        userName.textColor = color
        birthDay.textColor = color
    }
    func configureDatePicker() {
        birthDay.inputView = datePicker
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector (doneClicked))
        toolBar.setItems([doneButton], animated: true)
        birthDay.inputAccessoryView = toolBar
        datePicker.datePickerMode = .date
    }
    func doneClicked() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        view.endEditing(true)
        birthDay.text =  dateFormatter.string(from: datePicker.date)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if(firstName.isEditing){
            firstName.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            firstName.textColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        }
        else{
            firstName.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        }
        if(lastName.isEditing){
            lastName.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            lastName.textColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        }
        else{
            lastName.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        }
        if(userName.isEditing){
            userName.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            userName.textColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        }
        else{
            userName.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        }
        if(birthDay.isEditing){
            birthDay.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            birthDay.textColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        }
        else{
            birthDay.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        firstName.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        lastName.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        firstName.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        lastName.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        userName.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        userName.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        birthDay.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        birthDay.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
