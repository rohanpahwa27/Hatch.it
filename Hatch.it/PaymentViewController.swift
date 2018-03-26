//
//  PaymentViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 3/11/18.
//  Copyright © 2018 Hatch Inc. All rights reserved.
//

import UIKit
import Stripe
import Alamofire
import AudioToolbox
import Firebase
struct charge {
    static var amount = 0.0
    static var acct = ""
}
class PaymentViewController: UIViewController, STPPaymentCardTextFieldDelegate {

    
    let paymentTextField = STPPaymentCardTextField()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var payButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        amount.isHidden = true
        amount.text = "$\(charge.amount)0 + transaction fees"
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(tap)
        displayView.layer.cornerRadius = 10
        payButton.isHidden = true
        paymentTextField.frame = CGRect(x: 15, y: 199, width: Int(self.displayView.frame.width - 30), height: 44)
        paymentTextField.center = displayView.center
        paymentTextField.delegate = self
        view.addSubview(paymentTextField)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = displayView.center
        view.addSubview(activityIndicator)
        // Do any additional setup after loading the view.
    }
    @IBAction func payUser(_ sender: UIButton) {
        activityIndicator.startAnimating()
        let card = paymentTextField.cardParams
        let requestString = "https://secret-shore-27202.herokuapp.com/charge.php"
        let params = ["number": card.number!, "exp_month": card.expMonth, "exp_year": card.expYear, "cvc": card.cvc!, "amount": charge.amount * 100, "currency": "usd", "description": "Hatch.it Event", "fee": round((charge.amount * 0.03) * 100), "destination": charge.acct] as [String : Any]
        Alamofire.request(requestString, method: .post, parameters: params)
            .responseJSON { response in
                if(response.response?.statusCode != 200){
                    let alert = UIAlertController(title: "Error", message: "There Was An Error Processing Your Request", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    let uid = Auth.auth().currentUser?.uid
                    let genNum = NSUUID().uuidString
                    AudioServicesPlaySystemSound(1520)
                    self.payButton.setTitle("Completed", for: .normal)
                    self.payButton.isEnabled = false
                    self.paymentTextField.isEnabled = false
                    self.activityIndicator.stopAnimating()
                    Database.database().reference().child("Events").child(variables.uuid).child("Users Going").updateChildValues([genNum: uid!])
                    
                }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func dismissView() {
        if(paymentTextField.isFirstResponder){
            view.endEditing(true)
        }
        else {
            dismiss(animated: true, completion: nil)
        }
    }
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        if(textField.isValid){
           payButton.isHidden = false
           amount.isHidden = false
        }
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
