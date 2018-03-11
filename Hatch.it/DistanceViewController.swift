//
//  DistanceViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 2/5/18.
//  Copyright © 2018 Hatch Inc. All rights reserved.
//

import UIKit
struct open {
    static var slider = 250.0
}
class DistanceViewController: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var slider: UISlider!
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.layer.cornerRadius = 10
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(tap)
        slider.value = Float(open.slider / 500)
        distance.text = "\(Int(open.slider)) mi"
        // Do any additional setup after loading the view.
    }

    @IBAction func sliderMoved(_ sender: UISlider) {
        distance.text = "\(Int(sender.value * 500)) mi"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func dismissView() {
        open.slider = Double(slider.value * 500)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callForAlert3"), object: nil)
        dismiss(animated: true, completion: nil)
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
