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
class PaymentViewController: UIViewController, STPPaymentCardTextFieldDelegate {

    
    let paymentTextField = STPPaymentCardTextField()

    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var payButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(tap)
        displayView.layer.cornerRadius = 10
        payButton.isHidden = true
        paymentTextField.frame = CGRect(x: 15, y: 199, width: Int(self.displayView.frame.width - 30), height: 44)
        paymentTextField.center = displayView.center
        paymentTextField.delegate = self
        view.addSubview(paymentTextField)
        // Do any additional setup after loading the view.
    }

    @IBAction func payUser(_ sender: UIButton) {
        let card = paymentTextField.cardParams
        STPAPIClient.shared().createToken(withCard: card, completion: {(token, error) -> Void in
            if let error = error {
                print(error)
            }
            else if let token = token {
                print(token)
                self.chargeUsingToken(token: token)
            }
        })
    }
    func chargeUsingToken(token:STPToken) {
        let requestString = "https://secret-shore-27202.herokuapp.com/charge.php"
        let params = ["stripeToken": token.tokenId, "amount": "0.01", "currency": "usd", "description": "testRun"]
        //This line of code will suffice, but we want a response
        Alamofire.request(requestString, method: .post, parameters: params)
        //with response handler:
        Alamofire.request(requestString, method: .post, parameters: params)
            .responseJSON { response in
                //print(response.request) // original URL request
                //print(response.response) // URL response
                //print(response.data) // server data
                print(response.result) // result of response serialization
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        if(textField.isValid){
           payButton.isHidden = false
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
