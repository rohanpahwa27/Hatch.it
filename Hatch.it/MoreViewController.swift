//
//  MoreViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 9/13/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
import Photos
class MoreViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    let loader = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let refresher = UIRefreshControl()
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    
    let gradientOne = UIColor(red: 139/255, green: 34/255, blue: 34/255, alpha: 1).cgColor
    let gradientThree = UIColor(red: 225/255, green: 201/255, blue: 222/255, alpha: 1).cgColor
    let gradientTwo = UIColor(red: 239/255, green: 59/255, blue: 51/255, alpha: 1).cgColor
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var picLoader: UIActivityIndicatorView!
    func animateGradient() {
        if currentGradient < gradientSet.count - 1 {
            currentGradient += 1
        } else {
            currentGradient = 0
        }
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.repeatCount = Float.infinity
        gradientChangeAnimation.autoreverses = true
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradientChangeAnimation.duration = 2.0
        gradientChangeAnimation.toValue = gradientSet[currentGradient]
        gradientChangeAnimation.fillMode = kCAFillModeForwards
        gradient.add(gradientChangeAnimation, forKey: "colorChange")
        
    }
    @IBAction func uploadImage(_ sender: UIButton) {
        PHPhotoLibrary.requestAuthorization({
            (newStatus) in
            if newStatus ==  PHAuthorizationStatus.authorized {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = true
                picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                DispatchQueue.main.async {
                }
                self.present(picker, animated: true, completion: nil)
            }
            else
            {
                let alert = UIAlertController(title: "App Permission Denied", message: "To re-enable, please go to Settings and turn on Photo Library Access for this app.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    override func viewDidLayoutSubviews() {
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 100)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        picLoader.hidesWhenStopped = true
        picLoader.startAnimating()
        view.addSubview(loader)
        view.addSubview(scrollView)
        refresher.attributedTitle = NSAttributedString(string: "Pull Down to Refresh")
        refresher.addTarget(self, action: #selector(viewDidAppear(_:)), for: UIControlEvents.valueChanged)
        scrollView.addSubview(refresher)
        view.backgroundColor = UIColor.init(red: 195/255, green: 197/255, blue: 198/255, alpha: 1)
        profilePicture.clipsToBounds = true
        
        }
    
        // Do any additional setup after loading the view.
    override func viewDidAppear(_ animated: Bool) {
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        ref.child("Users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot)
            in
            if let dict = snapshot.value as? [String: AnyObject]
            {
                self.firstName.text! = dict["First Name"] as! String
                self.lastName.text! = dict["Last Name"] as! String
                self.userName.text! = dict["Username"] as! String
                if let profilePictureUrl = dict["Profile Picture"] as? String{
                    if(profilePictureUrl == "default.png"){
                        self.picLoader.stopAnimating()
                    }
                    else{
                        let url = URL(string: profilePictureUrl)
                        URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                            if(error != nil)
                            {
                            }
                            else{
                                DispatchQueue.main.async {
                                    self.profilePicture.image = UIImage(data: data!)
                                    self.picLoader.stopAnimating()
                                }
                            }
                        
                        }).resume()
                    }
                }
            }
        })
        gradientSet.append([gradientOne, gradientTwo])
        gradientSet.append([gradientTwo, gradientThree])
        gradientSet.append([gradientThree, gradientOne])
        gradient.frame = borderView.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        gradient.drawsAsynchronously = true
        borderView.layer.addSublayer(gradient)
        animateGradient()
        refresher.endRefreshing()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker
        {
            profilePicture.image = selectedImage
            let uid = Auth.auth().currentUser?.uid
            let storageRef = Storage.storage().reference().child("profilePicture").child(uid!)
            let uploadData = UIImageJPEGRepresentation(self.profilePicture.image!, 0.0)
            storageRef.putData(uploadData!, metadata: nil, completion: {(metadata, error) in
                if(error == nil)
                {
                    let ref = Database.database().reference()
                    ref.child("Users").child(uid!).updateChildValues(["Profile Picture": metadata?.downloadURL()?.absoluteString as Any])
                }
            })
           
        }
        dismiss(animated: true, completion: nil)
    }
}
