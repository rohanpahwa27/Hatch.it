//
//  CreateAccountViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 9/18/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth
import UserNotifications
class CreateAccountViewController: UIViewController, UITextFieldDelegate, UNUserNotificationCenterDelegate {
    
    //IBOutlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var theScrollView: UIScrollView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var createPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var userBirthday: UITextField!
    //Variables and Constants
    var ref: DatabaseReference!
    let datePicker = UIDatePicker()
    var date = ""
    //IBActions
    @IBAction func createAccountPressed(_ sender: UIButton) {
        if(firstName.text! == "" || lastName.text! == "" || userEmail.text! == "" || createPassword.text! == "" || confirmPassword.text! == "" || date == ""){
            let alert = UIAlertController(title: "Error", message: "Fields Cannot be Left Blank", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else{
            if(createPassword.text! != confirmPassword.text!){
                
                let alert = UIAlertController(title: "Error", message: "Passwords Do Not Match", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                Auth.auth().createUser(withEmail: userEmail.text!, password: createPassword.text!) { (user, error) in
                    if(error == nil)
                    {
                        let content = UNMutableNotificationContent()
                        let genNum = NSUUID().uuidString
                        let currDate = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                        let dateString: String = dateFormatter.string(from: currDate)
                        content.title = "Welcome"
                        content.body = "Welcome To Hatch.it, \(self.firstName.text!)!"
                        let notifInfo = ["Notification Title": content.title, "Notification Body": content.body, "Notification UID": genNum, "Notification Time": dateString]
                        self.ref.child("Notifications").child(user!.uid).child(genNum).setValue(notifInfo)
                        content.sound = UNNotificationSound.default()
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
                        let request = UNNotificationRequest(identifier: "Welcome", content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                        let info = [
                            "First Name":  self.firstName.text!,
                            "Last Name": self.lastName.text!,
                            "Email": self.userEmail.text!,
                            "Username": self.userName.text!,
                            "Birthday": self.date,
                            "Profile Picture": "default.png"
                        ]
                        self.performSegue(withIdentifier: "createAccount", sender: self)
                        self.ref.child("Users").child(user!.uid).setValue(info)
                        Auth.auth().currentUser?.sendEmailVerification { (error) in
                            if(error != nil){
                                let alert = UIAlertController(title: "Error", message: "An error has occured. Verification Email Could Not Be Sent", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    else{
                        if let errCode = AuthErrorCode(rawValue: error!._code) {
                            switch errCode {
                            case .emailAlreadyInUse:
                                let alert = UIAlertController(title: "Error", message: "The email is already in use with another account", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                            case .invalidEmail, .invalidSender, .invalidRecipientEmail:
                                print("test")
                                let alert = UIAlertController(title: "Error", message: "Please enter a valid email", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                            case .networkError:
                                let alert = UIAlertController(title: "Error", message: "Network error. Please try again.", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                            case .weakPassword:
                                let alert = UIAlertController(title: "Error", message: "Please enter a password that is at least 6 characters long", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                            default:
                                let alert = UIAlertController(title: "Error", message: "Unknown error occurred", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        
    }
    //Override Functions
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidLayoutSubviews() {
        theScrollView.isScrollEnabled = true
        theScrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 100)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 69/255, green: 104/255, blue: 220/255, alpha: 1)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(red: 69/255, green: 104/255, blue: 220/255, alpha: 1)
        UNUserNotificationCenter.current().delegate = self
        ref = Database.database().reference()
        self.firstName.delegate = self
        self.lastName.delegate = self
        self.userEmail.delegate = self
        self.userName.delegate = self
        self.createPassword.delegate = self
        self.confirmPassword.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        configureDatePicker()
        configureScheme()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    //Functions
    func configureScheme() {
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
        firstName.layer.borderWidth = 1
        lastName.layer.borderWidth = 1
        userName.layer.borderWidth = 1
        userEmail.layer.borderWidth = 1
        userBirthday.layer.borderWidth = 1
        createPassword.layer.borderWidth = 1
        confirmPassword.layer.borderWidth = 1
        firstName.layer.borderColor = UIColor.white.cgColor
        lastName.layer.borderColor = UIColor.white.cgColor
        userName.layer.borderColor = UIColor.white.cgColor
        userEmail.layer.borderColor = UIColor.white.cgColor
        userBirthday.layer.borderColor = UIColor.white.cgColor
        createPassword.layer.borderColor = UIColor.white.cgColor
        confirmPassword.layer.borderColor = UIColor.white.cgColor
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    func configureDatePicker() {
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
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(firstName.isEditing){
            firstName.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
            firstName.textColor = UIColor.black
        }
        else{
            firstName.backgroundColor = UIColor.clear
        }
        if(lastName.isEditing){
            lastName.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
            lastName.textColor = UIColor.black
        }
        else{
            lastName.backgroundColor = UIColor.clear
        }
        if(userName.isEditing){
            userName.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
            userName.textColor = UIColor.black
        }
        else{
            userName.backgroundColor = UIColor.clear
        }
        if(datePicker.isHidden){
            userBirthday.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
            userBirthday.textColor = UIColor.black
        }
        else{
            userBirthday.backgroundColor = UIColor.clear
        }
        if(createPassword.isEditing){
            createPassword.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
            createPassword.textColor = UIColor.black
        }
        else{
            createPassword.backgroundColor = UIColor.clear
        }
        if(confirmPassword.isEditing){
            confirmPassword.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
            confirmPassword.textColor = UIColor.black
        }
        else{
            confirmPassword.backgroundColor = UIColor.clear
        }
        if(userEmail.isEditing){
            userEmail.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
            userEmail.textColor = UIColor.black
        }
        else{
            userEmail.backgroundColor = UIColor.clear
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        firstName.textColor = UIColor.white
        lastName.textColor = UIColor.white
        lastName.backgroundColor = UIColor.clear
        firstName.backgroundColor = UIColor.clear
        userName.textColor = UIColor.white
        userName.backgroundColor = UIColor.clear
        userBirthday.textColor = UIColor.white
        userBirthday.backgroundColor = UIColor.clear
        createPassword.textColor = UIColor.white
        createPassword.backgroundColor = UIColor.clear
        confirmPassword.textColor = UIColor.white
        confirmPassword.backgroundColor = UIColor.clear
        userEmail.textColor = UIColor.white
        userEmail.backgroundColor = UIColor.clear
    }
    func doneClicked() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        view.endEditing(true)
        userBirthday.text =  dateFormatter.string(from: datePicker.date)
        date = dateFormatter.string(from: datePicker.date)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}
