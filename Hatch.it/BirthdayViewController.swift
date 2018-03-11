//
//  BirthdayViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 12/9/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
class BirthdayViewController: UIViewController {
    //Variables and Constants
    let datePicker = UIDatePicker()
    //IBOutlets
    @IBOutlet weak var userBirthday: UITextField!
    @IBOutlet weak var backgroundView: UIView!
    //IBActions
    @IBAction func updateBirthday(_ sender: UIButton) {
        let uid = Auth.auth().currentUser?.uid
        if(userBirthday.text == ""){
            let alert = UIAlertController(title: "Error", message: "Fields Cannot Be Left Blank", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else{
           Database.database().reference().child("Users").child(uid!).child("Birthday").setValue(userBirthday.text)
            self.performSegue(withIdentifier: "birthday", sender: self)
        }
    }
    //Override Functions
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(red: 69/255, green: 104/255, blue: 220/255, alpha: 1)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        configureDatePicker()
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //Functions
    func dismissKeyboard() {
        view.endEditing(true)
    }
    func configureDatePicker() {
        userBirthday.layer.borderWidth = 1
        userBirthday.layer.borderColor = UIColor.white.cgColor
        var components = DateComponents()
        components.year = -0
        let maxDate = Calendar.current.date(byAdding: components, to: Date())
        datePicker.maximumDate = maxDate
        userBirthday.inputView = datePicker
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector (doneClicked))
        toolBar.setItems([doneButton], animated: true)
        userBirthday.inputAccessoryView = toolBar
        datePicker.datePickerMode = .date
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        userBirthday.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        userBirthday.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
    }
    func doneClicked() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        view.endEditing(true)
        userBirthday.text =  dateFormatter.string(from: datePicker.date)
        userBirthday.text = dateFormatter.string(from: datePicker.date)
    }
}
