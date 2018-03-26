//
//  BankViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 3/14/18.
//  Copyright © 2018 Hatch Inc. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import SkyFloatingLabelTextField
struct bank {
    static var accountHolder = ""
    static var accountNumber = ""
    static var routingNumber = ""
    static var success = false
}
class BankViewController: UIViewController, UITextFieldDelegate {
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var accountHolder: SkyFloatingLabelTextField!
    @IBOutlet weak var accountNumber: SkyFloatingLabelTextField!
    @IBOutlet weak var routingNumber: SkyFloatingLabelTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        bgView.addGestureRecognizer(tap)
        bgView.layer.cornerRadius = 10
        accountHolder.delegate = self
        accountHolder.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        accountNumber.delegate = self
        accountNumber.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        routingNumber.delegate = self
        routingNumber.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = bgView.center
        bgView.addSubview(activityIndicator)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            return
        }
        if(textField == accountNumber){
            let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789")
            let textCharacterSet = CharacterSet.init(charactersIn: text)
            if (!allowedCharacterSet.isSuperset(of: textCharacterSet)) {
                accountNumber.errorMessage = "Invalid Number"
            }
            else {
                accountNumber.errorMessage = ""
            }
        }
        else if(textField == accountHolder){
            let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789")
            let textCharacterSet = CharacterSet.init(charactersIn: text)
            if (allowedCharacterSet.isSuperset(of: textCharacterSet)) {
                accountHolder.errorMessage = "Invalid Entry"
            }
            else {
                accountHolder.errorMessage = ""
            }
        }
        else if(textField == routingNumber){
            let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789")
            let textCharacterSet = CharacterSet.init(charactersIn: text)
            if (!allowedCharacterSet.isSuperset(of: textCharacterSet)) {
                routingNumber.errorMessage = "Invalid Number"
            }
            else if(text.count != 9){
                routingNumber.errorMessage = "Invalid Number"
            }
            else {
                routingNumber.errorMessage = ""
            }
        }
    }
    @IBAction func connectBank(_ sender: UIButton) {
        if(!accountHolder.hasErrorMessage && !accountNumber.hasErrorMessage && !routingNumber.hasErrorMessage && accountHolder.text != "" && accountNumber.text != "" && routingNumber.text != ""){
            activityIndicator.startAnimating()
            bank.routingNumber = routingNumber.text!
            bank.accountNumber = accountNumber.text!
            bank.accountHolder = accountHolder.text!
            let requestString = "https://secret-shore-27202.herokuapp.com/account.php"
            let params = ["routing_number": bank.routingNumber, "account_holder_name": bank.accountHolder, "account_number": bank.accountNumber]
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
                        let bankID = jsonobject["id"] as! String
                        print(JSON)
                        let requestString = "https://secret-shore-27202.herokuapp.com/bank.php"
                        var acctID = ""
                        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).observe(.childAdded, with: { (snapshot) in
                            if(snapshot.key == "AcctID"){
                                acctID = snapshot.value as! String
                                print(acctID)
                                print(bankID)
                                let params = ["acctID": acctID, "token": bankID]
                                Alamofire.request(requestString, method: .post, parameters: params)
                                    .responseJSON { response in
                                        if let JSON = response.result.value {
                                            print(JSON)
                                            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).updateChildValues(["BankToken": bankID])
                                            self.activityIndicator.stopAnimating()
                                            bank.success = true
                                            self.performSegue(withIdentifier: "success", sender: self)
                                        }
                                }
                            }
                        })
                    }
            }
        }
        else{
            let alert = UIAlertController(title: "Error", message: "Fields Not Valid", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
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
