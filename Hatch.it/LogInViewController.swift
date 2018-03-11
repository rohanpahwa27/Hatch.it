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
import FBSDKLoginKit
import FBSDKCoreKit
struct merge {
    static var user = false
}
class LogInViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate, FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if(error == nil){
            if(!result.isCancelled){
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                Auth.auth().signIn(with: credential) { (user, error) in
                    if(error == nil){
                        Database.database().reference().child("Users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.hasChild("Birthday"){
                                self.performSegue(withIdentifier: "login", sender: self)
                            }
                            else{
                                let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "first_name, last_name, email, id"])
                                graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                                    if ((error) == nil) {
                                        guard let _result = result as? [String : Any] else { return }
                                        
                                        let firstName = _result["first_name"] as? String
                                        let lastName  = _result["last_name"] as? String
                                        let email  = _result["email"] as? String
                                        let userID = _result["id"] as? String
                                        let facebookProfileUrl = "http://graph.facebook.com/\(userID!)/picture?type=large"
                                        let info = ["First Name": firstName, "Last Name": lastName, "Email": email, "Username": email, "Profile Picture": facebookProfileUrl]
                                        Database.database().reference().child("Users").child(user!.uid).setValue(info)
                                        let content = UNMutableNotificationContent()
                                        let currDate = Date()
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                                        let dateString: String = dateFormatter.string(from: currDate)
                                        content.title = "Welcome"
                                        content.body = "Welcome To Hatch.it, \(firstName!) \(lastName!)!"
                                        content.sound = UNNotificationSound.default()
                                        let genNum = NSUUID().uuidString
                                        
                                        let notifInfo = ["Notification Title": content.title, "Notification Body": content.body, "Notification UID": genNum, "Notification Time": dateString]
                                        Database.database().reference().child("Notifications").child(user!.uid).child(genNum).setValue(notifInfo)
                                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
                                        let request = UNNotificationRequest(identifier: "Welcome", content: content, trigger: trigger)
                                        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                                        self.performSegue(withIdentifier: "login2", sender: self)
                                    }
                                })
                            }
                        })
                    }
                    else{
                        let alert = UIAlertController(title: "Error", message: "Email Address Already In Use, Link Facebook From Settings", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        //
    }
    
    let loader = UIActivityIndicatorView(activityIndicatorStyle: .white)
    //IBOutlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var forgotPassword: UIButton!
    @IBOutlet weak var theScrollView: UIScrollView!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
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
        loader.hidesWhenStopped = true
        loader.center = view.center
        view.addSubview(loader)
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: view.center.x - 60, y: forgotPassword.center.y + 70, width: 100, height: 50)
        theScrollView.addSubview(googleButton)
        let facebookButton = FBSDKLoginButton()
        let x1 = view.center.x
        let y1 = forgotPassword.center.y + 40
        facebookButton.center = CGPoint(x: x1, y: y1)
        facebookButton.readPermissions = ["public_profile", "email", "user_birthday"]
        theScrollView.addSubview(facebookButton)
        googleButton.addTarget(self, action: #selector(requestAccess), for: .touchDown)
        facebookButton.delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.userEmail.delegate = self
        self.userPassword.delegate = self
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
        loader.startAnimating()
        GIDSignIn.sharedInstance().signIn()
    }
    func configureEmail() {
        userEmail.layer.borderColor = UIColor.white.cgColor
        userEmail.layer.borderWidth = 1.0
    }
    func configurePassword() {
        userPassword.layer.borderColor = UIColor.white.cgColor
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
            userEmail.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
            userEmail.textColor = UIColor.black
        }
        else{
            userEmail.backgroundColor = UIColor.clear
        }
        if(userPassword.isEditing){
            userPassword.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
            userPassword.textColor = UIColor.black
        }
        else{
            userPassword.backgroundColor = UIColor.clear
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        userEmail.textColor = UIColor.white
        userPassword.textColor = UIColor.white
        userPassword.backgroundColor = UIColor.clear
        userEmail.backgroundColor = UIColor.clear
    }
    //Google Sign In
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            self.loader.stopAnimating()
            return
        }
        if let authentication = user.authentication
        {
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential, completion: { (user, error) -> Void in
                if error != nil{
                    self.loader.stopAnimating()
                    return
                }
                else if error == nil{
                    Database.database().reference().child("Users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.hasChild("Birthday"){
                            self.loader.stopAnimating()
                            self.performSegue(withIdentifier: "login", sender: self)
                        }
                        else{
                            let content = UNMutableNotificationContent()
                            let currDate = Date()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                            let dateString: String = dateFormatter.string(from: currDate)
                            content.title = "Welcome"
                            content.body = "Welcome To Hatch.it, \(user?.displayName ?? "")!"
                            content.sound = UNNotificationSound.default()
                            let genNum = NSUUID().uuidString
                            
                            let notifInfo = ["Notification Title": content.title, "Notification Body": content.body, "Notification UID": genNum, "Notification Time": dateString]
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
                            self.loader.stopAnimating()
                            self.performSegue(withIdentifier: "login2", sender: self)
                        }
                    })
                }
            })
        }
    }
}
