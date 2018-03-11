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
class EditProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    //Variables and Constants
    let overlay = UIView()
    let loader = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let datePicker = UIDatePicker()
    let ref = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    //IBOutlets
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var theScrollView: UIScrollView!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var bio: UITextView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var birthDay: UITextField!
    //IBActions
    @IBAction func saveChanges(_ sender: UIButton) {
        ref.child("Users").child(uid!).updateChildValues(["First Name": firstName.text! as Any])
        ref.child("Users").child(uid!).updateChildValues(["Last Name": lastName.text! as Any])
        ref.child("Users").child(uid!).updateChildValues(["Username": userName.text! as Any])
        ref.child("Users").child(uid!).updateChildValues(["Birthday": birthDay.text! as Any])
        ref.child("Users").child(uid!).updateChildValues(["Bio": bio.text! as Any])
        let alert = UIAlertController(title: "Success", message: "Profile Updated", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    //Override Functions
    override func viewDidLayoutSubviews() {
        theScrollView.isScrollEnabled = true
        theScrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 100)
    }
    func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        theScrollView.contentInset = contentInsets
        theScrollView.scrollIndicatorInsets = contentInsets
    }
    func keyboardWillHide(notification: NSNotification) {
        theScrollView.contentInset = .zero
        theScrollView.scrollIndicatorInsets = .zero
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
        loader.hidesWhenStopped = true
        loader.center.x = view.frame.width/2
        loader.center.y = firstName.center.y - 50
        view.addSubview(loader)
        loader.startAnimating()
        configureDatePicker()
        displayInfo()
        self.bio.delegate = self
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
                self.birthDay.text = dict["Birthday"] as? String
                self.bio.text = dict["Bio"] as? String
                if(self.bio.text == nil || self.bio.text == ""){
                    self.bio.text = "Bio"
                    self.bio.textColor = UIColor.lightGray
                }
            }
            self.loader.stopAnimating()
        })
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
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(bio.text == "Bio"){
            bio.text = ""
            bio.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if(bio.text == ""){
            bio.text = "Bio"
            bio.textColor = UIColor.lightGray
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
