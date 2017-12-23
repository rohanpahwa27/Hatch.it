//
//  LogInViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 9/20/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn
import UserNotifications
class LogInViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
    //IBOutlets
    @IBOutlet weak var forgotPassword: UIButton!
    @IBOutlet weak var theScrollView: UIScrollView!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var logoImage: UIImageView!
    //IBActions
    @IBAction func logInPressed(_ sender: UIButton) {
        if(userEmail.text! == "" || userPassword.text! == ""){
            let alert = UIAlertController(title: "Error", message: "Fields Cannot Be Blank", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else{
            Auth.auth().signIn(withEmail: userEmail.text!, password: userPassword.text!) { (user, error) in
                if(error == nil){
                    if(Auth.auth().currentUser?.isEmailVerified == true){
                        self.performSegue(withIdentifier: "login", sender: self)
                    }
                    else{
                        let alert = UIAlertController(title: "Error", message: "Email Is Not Verifed", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Send Verification Email", style: .default, handler:{
                            action in
                            Auth.auth().currentUser?.sendEmailVerification()
                            Auth.auth().currentUser?.reload(completion:  { (error) in  })
                        })
                        let action2 = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                        alert.addAction(action)
                        alert.addAction(action2)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else{
                    let alert = UIAlertController(title: "Error", message: "We do not recognize your email/password", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    //Override Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: view.center.x - 60, y: forgotPassword.center.y + 80, width: 100, height: 50)
        theScrollView.addSubview(googleButton)
        googleButton.addTarget(self, action: #selector(requestAccess), for: .touchDown)
        GIDSignIn.sharedInstance().uiDelegate = self
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        self.userEmail.delegate = self
        self.userPassword.delegate = self
        configureLogoImage()
        configureEmail()
        configurePassword()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidLayoutSubviews() {
        theScrollView.isScrollEnabled = true
        theScrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 100)
    }
    //Functions
    func requestAccess() {
        GIDSignIn.sharedInstance().signIn()
    }
    func configureLogoImage () {
        logoImage.clipsToBounds = true
        logoImage.layer.cornerRadius = logoImage.frame.height / 2
    }
    func configureEmail() {
        let myColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        userEmail.layer.borderColor = myColor.cgColor
        userEmail.layer.borderWidth = 1.0
    }
    func configurePassword() {
        let myColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        userPassword.layer.borderColor = myColor.cgColor
        userPassword.layer.borderWidth = 1.0
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        if(userPassword.isEditing){
            userPassword.backgroundColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 0.5)
            userPassword.textColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        }
        else{
            userPassword.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        userEmail.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        userPassword.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
        userPassword.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        userEmail.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
    }
    //Google Sign In
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            return
        }
        if let authentication = user.authentication
        {
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential, completion: { (user, error) -> Void in
                if error != nil{
                    return
                }
                else if error == nil{
                    Database.database().reference().child("Users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if snapshot.hasChild("Birthday"){
                            self.performSegue(withIdentifier: "login", sender: self)
                        }
                        else{
                            let content = UNMutableNotificationContent()
                            content.title = "Hatch.it"
                            content.subtitle = "Notification"
                            content.body = "Welcome To Hatch.it, \(user?.displayName ?? "")!"
                            content.sound = UNNotificationSound.default()
                            let genNum = NSUUID().uuidString
                            let notifInfo = ["Notification Title": content.title, "Notification Subtitle": content.subtitle, "Notification Body": content.body]
                            Database.database().reference().child("Notifications").child(user!.uid).child(genNum).setValue(notifInfo)
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
                            let request = UNNotificationRequest(identifier: "Welcome", content: content, trigger: trigger)
                            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                            let fullName = user?.displayName
                            let fullNameArr = fullName!.components(separatedBy: " ")
                            let firstName = fullNameArr[0]
                            let lastName = fullNameArr[1]
                            let email = user?.email
                            let userName = user?.email
                            let profilePicture = "default.png"
                            let birthday = ""
                            let info = ["First Name": firstName, "Last Name": lastName, "Email": email, "Username": userName, "Birthday": birthday, "Profile Picture": profilePicture]
                            let ref = Database.database().reference()
                            ref.child("Users").child(user!.uid).setValue(info)
                            self.performSegue(withIdentifier: "login2", sender: self)
                        }
                    })
                }
            })
        }
    }
}
