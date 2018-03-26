//
//  CreateStripeAccountViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 3/14/18.
//  Copyright © 2018 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SkyFloatingLabelTextField
struct register {
    static var day = ""
    static var month = ""
    static var year = ""
    static var street = ""
    static var city = ""
    static var state = ""
    static var zip = ""
    static var ssn = ""
    static var bank = false
}
class CreateStripeAccountViewController: UIViewController, UITextViewDelegate,  UITextFieldDelegate {

    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    @IBOutlet weak var dayTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var monthTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var yearTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var streetTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var zipTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var ssn: SkyFloatingLabelTextField!
    @IBOutlet weak var cityTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var stateTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var conditions: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.isHidden = true
        zipTextField.delegate = self
        dayTextField.delegate = self
        monthTextField.delegate = self
        yearTextField.delegate = self
        streetTextField.delegate = self
        cityTextField.delegate = self
        stateTextField.delegate = self
        ssn.delegate = self
        popupView.layer.cornerRadius = 10
        ssn.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        zipTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        dayTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        monthTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        yearTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        streetTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cityTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        stateTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.bgView.layer.cornerRadius = 10
        conditions.font = UIFont(name: "Lato-Light", size: 10)
        let linkAttributes = [
            NSLinkAttributeName: NSURL(string: "https://stripe.com/us/connect-account/legal")!,
            NSForegroundColorAttributeName: UIColor.blue, NSFontAttributeName: UIFont(name: "Lato-Light", size: 10)!] as [String : Any]
        let stringAttributes = [NSFontAttributeName: UIFont(name: "Lato-Light", size: 10)!] as [String : Any]
        let attributedString = NSMutableAttributedString(string: "By registering your account, you agree to our Services Agreement and the Stripe Connected Account Agreement.")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        bgView.addGestureRecognizer(tap)
        let tap2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(tap2)
        attributedString.setAttributes(stringAttributes, range: NSMakeRange(0, 108))
        attributedString.setAttributes(linkAttributes, range: NSMakeRange(73, 35))
        self.conditions.delegate = self
        self.conditions.attributedText = attributedString
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = bgView.center
        scrollView.addSubview(activityIndicator)
        // Do any additional setup after loading the view.
    }
    @IBAction func registerAccount(_ sender: UIButton) {
        if(!dayTextField.hasErrorMessage && !monthTextField.hasErrorMessage && !yearTextField.hasErrorMessage && !streetTextField.hasErrorMessage && !cityTextField.hasErrorMessage && !stateTextField.hasErrorMessage && !zipTextField.hasErrorMessage && !ssn.hasErrorMessage && dayTextField.text != "" && monthTextField.text != "" && yearTextField.text != "" && streetTextField.text != "" && cityTextField.text != "" && stateTextField.text != "" && zipTextField.text != "" && ssn.text != ""){
            activityIndicator.startAnimating()
            register.day = dayTextField.text!
            register.month = monthTextField.text!
            register.year = yearTextField.text!
            register.street = streetTextField.text!
            register.city = cityTextField.text!
            register.state = stateTextField.text!
            register.zip = zipTextField.text!
            register.ssn = ssn.text!
            var email = ""
            var firstName = ""
            var lastName = ""
            var uid = ""
            Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
                if(snapshot.key == Auth.auth().currentUser?.uid){
                    uid = snapshot.key
                    for child in snapshot.children.allObjects as! [DataSnapshot]{
                        if(child.key == "Email"){
                            email = child.value as! String
                        }
                        if(child.key == "First Name"){
                            firstName = child.value as! String
                        }
                        if(child.key == "Last Name"){
                            lastName = child.value as! String
                        }
                    }
                    let requestString = "https://secret-shore-27202.herokuapp.com/create.php"
                    let params = ["email": email, "firstName": firstName, "lastName": lastName, "day": register.day, "month": register.month, "year": register.year, "street": register.street, "city": register.city, "state": register.state, "zip": register.zip, "ssn": register.ssn]
                    Alamofire.request(requestString, method: .post, parameters: params)
                        .responseJSON { response in
                            if(response.response?.statusCode != 200){
                                let alert = UIAlertController(title: "Error", message: "There Was An Error Processing Your Request", preferredStyle: .alert)
                                let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                            }
                            if let JSON = response.result.value {
                                var jsonobject = JSON as! [String: AnyObject]
                                let acctID = jsonobject["id"] as! String
                                self.activityIndicator.stopAnimating()
                                globalVariables.success = true
                                print(JSON)
                                Database.database().reference().child("Users").child(uid).updateChildValues(["AcctID": acctID])
                                self.performSegue(withIdentifier: "bank", sender: self)
                            }
                    }
                }
            })
        }
        else{
            let alert = UIAlertController(title: "Error", message: "Fields Not Valid", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func infoPressed(_ sender: UIButton) {
        if(popupView.isHidden){
            popupView.isHidden = false
        }
        else{
            popupView.isHidden = true
        }
    }
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            return
        }
        if(textField == dayTextField){
            let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789")
            let textCharacterSet = CharacterSet.init(charactersIn: text)
            if (!allowedCharacterSet.isSuperset(of: textCharacterSet)) {
                dayTextField.errorMessage = "Invalid Date"
            }
            else if(Int(text)! > 31 || Int(text)! < 1) {
                dayTextField.errorMessage = "Invalid Date"
            }
            else {
                dayTextField.errorMessage = ""
            }
        }
        if(textField == ssn){
            let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789")
            let textCharacterSet = CharacterSet.init(charactersIn: text)
            if (!allowedCharacterSet.isSuperset(of: textCharacterSet)) {
                ssn.errorMessage = "Invalid SSN"
            }
            else if(text.count != 9) {
                ssn.errorMessage = "Invalid SSN"
            }
            else {
                ssn.errorMessage = ""
            }
        }
        else if(textField == monthTextField){
            let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789")
            let textCharacterSet = CharacterSet.init(charactersIn: text)
            if (!allowedCharacterSet.isSuperset(of: textCharacterSet)) {
                monthTextField.errorMessage = "Invalid Month"
            }
            else if(Int(text)! > 12 || Int(text)! < 1) {
                monthTextField.errorMessage = "Invalid Month"
            }
            else {
                monthTextField.errorMessage = ""
            }
        }
        else if(textField == yearTextField){
            let date = Date()
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789")
            let textCharacterSet = CharacterSet.init(charactersIn: text)
            if (!allowedCharacterSet.isSuperset(of: textCharacterSet)) {
                yearTextField.errorMessage = "Invalid Year"
            }
            else if(Int(text)! > year || Int(text)! < 1900) {
                yearTextField.errorMessage = "Invalid Year"
            }
            else {
                yearTextField.errorMessage = ""
            }
        }
        else if(textField == cityTextField){
            let allowedCharacterSet = CharacterSet.init(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
            let textCharacterSet = CharacterSet.init(charactersIn: text)
            if (!allowedCharacterSet.isSuperset(of: textCharacterSet)) {
                cityTextField.errorMessage = "Invalid City"
            }
            else{
                cityTextField.errorMessage = ""
            }
        }
        else if(textField == stateTextField){
            let allowedCharacterSet = CharacterSet.init(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
            let textCharacterSet = CharacterSet.init(charactersIn: text)
            if (!allowedCharacterSet.isSuperset(of: textCharacterSet)) {
                stateTextField.errorMessage = "Invalid State"
            }
            else{
                stateTextField.errorMessage = ""
            }
        }
        else if(textField == zipTextField){
            let allowedCharacterSet = CharacterSet.init(charactersIn: "1234567890")
            let textCharacterSet = CharacterSet.init(charactersIn: text)
            if (!allowedCharacterSet.isSuperset(of: textCharacterSet)) {
                zipTextField.errorMessage = "Invalid Zip"
            }
            else{
                zipTextField.errorMessage = ""
            }
        }
    }
    func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    override func viewDidLayoutSubviews() {
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width: bgView.frame.width, height: bgView.frame.height + 200)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
