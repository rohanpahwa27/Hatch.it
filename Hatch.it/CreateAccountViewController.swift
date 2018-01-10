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
                        content.title = "Hatch.it"
                        content.body = "Welcome To Hatch.it, \(self.firstName.text!)!"
                        let notifInfo = ["Notification Title": content.title, "Notification Title": content.body, "Notification UID": genNum]
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
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        ref = Database.database().reference()
        view.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
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
        let myColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        firstName.layer.borderWidth = 1
        lastName.layer.borderWidth = 1
        userName.layer.borderWidth = 1
        userEmail.layer.borderWidth = 1
        userBirthday.layer.borderWidth = 1
        createPassword.layer.borderWidth = 1
        confirmPassword.layer.borderWidth = 1
        firstName.layer.borderColor = myColor.cgColor
        lastName.layer.borderColor = myColor.cgColor
        userName.layer.borderColor = myColor.cgColor
        userEmail.layer.borderColor = myColor.cgColor
        userBirthday.layer.borderColor = myColor.cgColor
        createPassword.layer.borderColor = myColor.cgColor
        confirmPassword.layer.borderColor = myColor.cgColor
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
            firstName.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            firstName.textColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        else{
            firstName.backgroundColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        if(lastName.isEditing){
            lastName.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            lastName.textColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        else{
            lastName.backgroundColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        if(userName.isEditing){
            userName.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            userName.textColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        else{
            userName.backgroundColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        if(datePicker.isHidden){
            userBirthday.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            userBirthday.textColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        else{
            userBirthday.backgroundColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        if(createPassword.isEditing){
            createPassword.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            createPassword.textColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        else{
            createPassword.backgroundColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        if(confirmPassword.isEditing){
            confirmPassword.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            confirmPassword.textColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        else{
            confirmPassword.backgroundColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        if(userEmail.isEditing){
            userEmail.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            userEmail.textColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
        else{
            userEmail.backgroundColor = UIColor.init(red: 47/255, green: 55/255, blue: 58/255, alpha: 1)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        firstName.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        lastName.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        lastName.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        firstName.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        userName.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        userName.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        userBirthday.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        userBirthday.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        createPassword.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        createPassword.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        confirmPassword.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        confirmPassword.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        userEmail.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        userEmail.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
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
