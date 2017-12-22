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
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    
    @IBAction func uploadImage(_ sender: UIButton) {
        PHPhotoLibrary.requestAuthorization({
            (newStatus) in
            if newStatus ==  PHAuthorizationStatus.authorized {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = true
                picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 195/255, green: 197/255, blue: 198/255, alpha: 1)
        profilePicture.layer.cornerRadius = self.profilePicture.frame.height/2
        profilePicture.layer.borderWidth = 1
        profilePicture.layer.borderColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1).cgColor
        profilePicture.clipsToBounds = true
        
        }
    
        // Do any additional setup after loading the view.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
                    let url = URL(string: profilePictureUrl)
                    URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                        if(error != nil)
                        {
                            
                        }
                        else{
                            DispatchQueue.main.async {
                                self.profilePicture.image = UIImage(data: data!)
                            }
                        }
                        
                        
                    }).resume()
                    
                }
            }
        })
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
            let uploadData = UIImagePNGRepresentation(self.profilePicture.image!)
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
