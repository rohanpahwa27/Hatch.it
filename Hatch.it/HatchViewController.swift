//
//  SecondViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 9/13/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import GooglePlaces
import Photos
import Alamofire
import SafariServices
import UserNotifications
//Global Variables
struct globalVariables {
    static var event = Event()
    static var notification = [Notifiction]()
    static var success = false
    static var tempEvent = Event()
}
class HatchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UNUserNotificationCenterDelegate, SFSafariViewControllerDelegate {
    //IBOutlets
    @IBOutlet weak var chooseImage2: UIButton!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventType: UITextField!
    @IBOutlet weak var numOfHeads: UITextField!
    @IBOutlet weak var eventDate: UITextField!
    @IBOutlet weak var tag: UILabel!
    @IBOutlet weak var selectLocation: UITextField!
    @IBOutlet weak var chooseImage: UIButton!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var stripeSetup: UIButton!
    @IBOutlet weak var paymentField: UITextField!
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    @IBOutlet weak var eventVisibilityControl: UISegmentedControl!
    //Variables and Constants
    let loader = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var ref: DatabaseReference!
    let eventTypePicker = UIPickerView()
    let startTimePicker = UIPickerView()
    let endTimePicker = UIPickerView()
    let headsPicker = UIPickerView()
    var eventLocation: String?
    var eventAddress: String?
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    var uuid = ""
    let datePicker = UIDatePicker()
    var downloadURL: String?
    var locationPicked = false
    var picturePicked = false
    var eventVisibility = "Public"
    var eventPrice = "Free"
    var url: Any?
    let heads = ["Unlimited", "1", "2", "3","4","5", "6", "7", "8", "9", "10", "11", "12", "13","14","15", "16", "17", "18", "19", "20", "21", "22", "23","24","25", "26", "27", "28", "29", "30", "31", "32", "33","34","35", "36", "37", "38", "39", "40", "41", "42", "43","44","45", "46", "47", "48", "49", "50", "51", "52", "53","54","55", "56", "57", "58", "59", "60", "61", "62", "63","64","65", "66", "67", "68", "69", "70", "71", "72", "73","74","75", "76", "77", "78", "79", "80", "81", "82", "83","84","85", "86", "87", "88", "89", "90", "91", "92", "93", "94","95","96", "97", "98", "99", "100"]
    let pickerData = ["Sports", "Leisure", "Educational", "Hobbies", "Other"]
    let hour = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    let minute = ["00", "01", "02", "03","04","05", "06", "07", "08", "09", "10", "11", "12", "13","14","15", "16", "17", "18", "19", "20", "21", "22", "23","24","25", "26", "27", "28", "29", "30", "31", "32", "33","34","35", "36", "37", "38", "39", "40", "41", "42", "43","44","45", "46", "47", "48", "49", "50", "51", "52", "53","54","55", "56", "57", "58", "59"]
    let timeStamp = ["AM", "PM"]
    //IBActions
    @IBAction func eventVisibility(_ sender: UISegmentedControl) {
        if(eventVisibilityControl.selectedSegmentIndex == 0){
            eventVisibility = "Public"
        }
        else if(eventVisibilityControl.selectedSegmentIndex == 1){
            eventVisibility = "Private"
        }
    }
    @IBAction func chooseImage(_ sender: UIButton) {
        picturePicked = true
        PHPhotoLibrary.requestAuthorization({
            (newStatus) in
            if newStatus ==  PHAuthorizationStatus.authorized {
                let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.delegate = self
                picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.present(picker, animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title: "App Permission Denied", message: "To re-enable, please go to Settings and turn on Photo Library Access for this app.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    @IBAction func chooseLocation(_ sender: UIButton) {
        locationPicked = true
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    @IBAction func connectWithStripe(_ sender: UIButton) {
        /*
        let safariVC = SFSafariViewController(url: NSURL(string: "https://dashboard.stripe.com/oauth/authorize?response_type=code&client_id=ca_CDClhgO5YpGj9Mx9CTOOoO5Yr9DHr5RU&scope=read_write&redirect_uri=https://google.com")! as URL)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self*/
    }
    @IBOutlet weak var choosePrice: UISegmentedControl!
    @IBAction func setupPayment(_ sender: UIButton) {

        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            if(snapshot.key == Auth.auth().currentUser!.uid){
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    if(child.key == "AcctID"){
                        globalVariables.success = true
                    }
                    if(child.key == "BankToken"){
                        bank.success = true
                    }
                }
                    if(globalVariables.success == true && bank.success == true){
                        if(self.paymentField.text != nil && self.paymentField.text != "" && self.paymentField.text != "$0.00"){
                            if(self.paymentField.text != nil && self.paymentField.text != "" && self.paymentField.text != "$0.00"){
                                self.choosePrice.selectedSegmentIndex = 1
                                self.stripeSetup.isHidden = false
                                self.tag.isHidden = false
                                self.paymentField.isHidden = false
                                self.stripeSetup.setTitle("Completed", for: .normal)
                                self.stripeSetup.isEnabled = false
                                self.paymentField.isEnabled = false
                            }
                            else{
                                let alert = UIAlertController(title: "Error", message: "Enter Valid Amount", preferredStyle: .alert)
                                let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    else if(globalVariables.success == true){
                        if(self.paymentField.text != nil && self.paymentField.text != "" && self.paymentField.text != "$0.00"){
                            self.uuid = NSUUID().uuidString
                            if(self.picturePicked){
                                let storage = Storage.storage()
                                let uploadData = UIImageJPEGRepresentation(self.eventImage.image!, 0.0)
                                let storageRef = storage.reference().child("Event Images").child(self.uuid)
                                storageRef.putData(uploadData!).observe(.success) { (snapshot) in
                                    globalVariables.tempEvent.eventImage = snapshot.metadata?.downloadURL()?.absoluteString
                                }
                            }
                            globalVariables.tempEvent.eventName = self.eventName.text
                            globalVariables.tempEvent.eventType = self.eventType.text
                            globalVariables.tempEvent.eventDate = self.eventDate.text
                            globalVariables.tempEvent.eventVisibility = self.eventVisibility
                            globalVariables.tempEvent.eventDescription = self.eventDescription.text
                            globalVariables.tempEvent.numOfHead = self.numOfHeads.text
                            globalVariables.tempEvent.location = self.eventLocation
                            globalVariables.tempEvent.startTime = self.startTime.text
                            globalVariables.tempEvent.endTime = self.endTime.text
                            globalVariables.tempEvent.price = self.paymentField.text
                            globalVariables.tempEvent.eventAddress = self.eventAddress
                            globalVariables.tempEvent.long = self.longitude
                            globalVariables.tempEvent.lat = self.latitude
                            self.performSegue(withIdentifier: "bank2", sender: self)
                        }
                        else{
                            let alert = UIAlertController(title: "Error", message: "Enter Valid Amount", preferredStyle: .alert)
                            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    else{
                        if(self.paymentField.text != nil && self.paymentField.text != "" && self.paymentField.text != "$0.00"){
                            self.uuid = NSUUID().uuidString
                            if(self.picturePicked){
                                let storage = Storage.storage()
                                let uploadData = UIImageJPEGRepresentation(self.eventImage.image!, 0.0)
                                let storageRef = storage.reference().child("Event Images").child(self.uuid)
                                storageRef.putData(uploadData!).observe(.success) { (snapshot) in
                                    globalVariables.tempEvent.eventImage = snapshot.metadata?.downloadURL()?.absoluteString
                                }
                            }
                            globalVariables.tempEvent.eventName = self.eventName.text
                            globalVariables.tempEvent.eventType = self.eventType.text
                            globalVariables.tempEvent.eventDate = self.eventDate.text
                            globalVariables.tempEvent.eventVisibility = self.eventVisibility
                            globalVariables.tempEvent.eventDescription = self.eventDescription.text
                            globalVariables.tempEvent.numOfHead = self.numOfHeads.text
                            globalVariables.tempEvent.location = self.eventLocation
                            globalVariables.tempEvent.startTime = self.startTime.text
                            globalVariables.tempEvent.endTime = self.endTime.text
                            globalVariables.tempEvent.price = self.paymentField.text
                            globalVariables.tempEvent.eventAddress = self.eventAddress
                            globalVariables.tempEvent.long = self.longitude
                            globalVariables.tempEvent.lat = self.latitude
                            self.performSegue(withIdentifier: "payment", sender: self)
                        }
                        else{
                            let alert = UIAlertController(title: "Error", message: "Enter Valid Amount", preferredStyle: .alert)
                            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
        })
    }
    @IBAction func createEvent(_ sender: UIButton) {
        loader.startAnimating()
        if(eventName.text! == "" || eventType.text! == "" || eventDescription.text! == "" || numOfHeads.text! == "" || eventDate.text! == "" || startTime.text! == "" || endTime.text! == ""){
            loader.stopAnimating()
            let alert = UIAlertController(title: "Error", message: "Fields Cannot be Left Blank", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else if(choosePrice.selectedSegmentIndex == 1 && globalVariables.success == false && bank.success == false){
            loader.stopAnimating()
            let alert = UIAlertController(title: "Error", message: "You Must Finish The Payment Setup Process", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else if(locationPicked == false && globalVariables.success == false && bank.success == false){
            loader.stopAnimating()
            let alert = UIAlertController(title: "Error", message: "Please Choose A Location", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else if(picturePicked == false){
            loader.stopAnimating()
            let alert = UIAlertController(title: "Error", message: "Please Choose an Event Image", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else if(locationPicked == true){
            if(eventLocation == nil){
                loader.stopAnimating()
                let alert = UIAlertController(title: "Error", message: "Choose an Event Location", preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            else{
            uuid = NSUUID().uuidString
            let storage = Storage.storage()
            let uploadData = UIImageJPEGRepresentation(self.eventImage.image!, 0.0)
            let storageRef = storage.reference().child("Event Images").child(uuid)
            storageRef.putData(uploadData!).observe(.success) { (snapshot) in
                self.downloadURL = snapshot.metadata?.downloadURL()?.absoluteString
                self.ref.child("Events").child(self.uuid).updateChildValues(["Event Image": self.downloadURL as Any])
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM dd, yyyy 'at' h:mm a"
                let string = self.eventDate.text! + " at " + self.endTime.text!
                let finalDate = dateFormatter.date(from: string)
                let info = [
                    "Event Name":  self.eventName.text!,
                    "Event Type": self.eventType.text!,
                    "Date": self.eventDate.text!,
                    "Coded Date": "\(finalDate!)",
                    "Accessibility": self.eventVisibility,
                    "Event Description": self.eventDescription.text!,
                    "Number of Heads": self.numOfHeads.text!,
                    "Event Location": self.eventLocation!,
                    "Longitude": self.longitude,
                    "Latitude": self.latitude,
                    "Event Address": self.eventAddress!,
                    "Event UUID": self.uuid,
                    "Event Image": self.downloadURL,
                    "Start Time": self.startTime.text!,
                    "End Time": self.endTime.text!,
                    "Price Type": self.eventPrice,
                    "Price": self.paymentField.text!,
                    "Host": Auth.auth().currentUser?.uid
                    ] as [String : Any?]
                let content = UNMutableNotificationContent()
                let currDate = Date()
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                let dateString: String = dateFormatter1.string(from: currDate)
            
                content.title = "Congratulations!"
                content.body = "\(self.eventName.text!) has been Hatched"
                let notifInfo = ["Notification Title": content.title, "Notification Body": content.body, "Notification UID": self.uuid, "Notification Time": dateString, "Notification Image": self.downloadURL!]
                Database.database().reference().child("Notifications").child((Auth.auth().currentUser?.uid)!).child(self.uuid).setValue(notifInfo)
                content.sound = UNNotificationSound.default()
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
                let request = UNNotificationRequest(identifier: "Hatched", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                self.ref.child("Events").child(self.uuid).setValue(info)
                Database.database().reference().child("Events").child(self.uuid).child("Users Going").childByAutoId().setValue(Auth.auth().currentUser?.uid)
                let event = Event()
                event.eventName = self.eventName.text!
                event.eventType = self.eventType.text!
                event.eventDate = self.eventDate.text!
                event.codedDate = "\(finalDate!)"
                event.eventVisibility = self.eventVisibility
                event.eventDescription = self.eventDescription.text!
                event.numOfHead = self.numOfHeads.text!
                event.location = self.eventLocation!
                event.long = self.longitude
                event.lat = self.latitude
                event.uuid = self.uuid
                event.eventImage = self.downloadURL
                event.startTime = self.startTime.text!
                event.endTime = self.endTime.text!
                event.host = Auth.auth().currentUser?.uid
                globalEvent.eventList.append(event)
                self.locationPicked = false
                globalVariables.event.eventName = self.eventName.text
                globalVariables.event.eventVisibility = self.eventVisibility
                globalVariables.event.location = self.eventLocation!
                globalVariables.event.eventDate = self.eventDate.text
                globalVariables.event.eventDescription = self.eventDescription.text
                globalVariables.event.numOfHead = self.numOfHeads.text
                globalVariables.event.eventImage = self.downloadURL
                self.eventName.text = ""
                self.eventType.text = ""
                self.eventDescription.text = ""
                self.numOfHeads.text = ""
                self.eventDate.text = ""
                self.selectLocation.text = ""
                self.startTime.text = ""
                self.endTime.text = ""
                self.eventImage.image = nil
                self.chooseImage2.alpha = 0
                self.chooseImage.alpha = 1
                self.cameraIcon.alpha = 1
                self.overlayView.backgroundColor = UIColor.init(red: 188/255, green: 188/255, blue: 189/255, alpha: 0.8)
                self.loader.stopAnimating()
                self.performSegue(withIdentifier: "done", sender: sender)
            }
            }
        }
    }
    @objc private func textFieldDidChange(textField: UITextField) {
            let currentValue = textField.text?.replacingOccurrences(of: ".", with: "")
            let finalValue = currentValue?.replacingOccurrences(of: "$", with: "")
            let value = Double(finalValue!)! * 0.01
            textField.text = "$\(String(format: "%.2lf", value))"
    }
    @IBAction func chooseImage2(_ sender: UIButton) {
        picturePicked = true
        PHPhotoLibrary.requestAuthorization({
            (newStatus) in
            if newStatus ==  PHAuthorizationStatus.authorized {
                let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.delegate = self
                picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                
                self.present(picker, animated: true, completion: nil)
            }
        })}
    //Override Functions
    override func viewDidLayoutSubviews() {
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width: 375, height: 1100)
    }
    override func viewWillAppear(_ animated: Bool) {
        if(bank.success && globalVariables.success){
            choosePrice.selectedSegmentIndex = 1
            eventPrice = "Paid"
            stripeSetup.isHidden = false
            tag.isHidden = false
            paymentField.isHidden = false
            stripeSetup.setTitle("Completed", for: .normal)
            stripeSetup.isEnabled = false
            paymentField.isEnabled = false
            if(globalVariables.tempEvent.eventImage == nil){
                picturePicked = false
            }
            else{
                chooseImage.alpha = 0
                cameraIcon.alpha = 0
                chooseImage2.alpha = 1
                overlayView.alpha = 0
                picturePicked = true
                let url = URL(string: globalVariables.tempEvent.eventImage!)
                URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                    if(error != nil)
                    {
                    }
                    else{
                        DispatchQueue.main.async {
                            self.eventImage.image = UIImage(data: data!)
                        }
                    }
                    
                }).resume()
            }
            if(globalVariables.tempEvent.location != nil){
                locationPicked = true
                eventLocation = globalVariables.tempEvent.location
                longitude = globalVariables.tempEvent.long!
                latitude = globalVariables.tempEvent.lat!
                eventAddress = globalVariables.tempEvent.eventAddress!
            }
            else{
                locationPicked = false
            }
            paymentField.text = globalVariables.tempEvent.price
            eventName.text = globalVariables.tempEvent.eventName
            eventType.text = globalVariables.tempEvent.eventType
            eventDate.text = globalVariables.tempEvent.eventDate
            if(globalVariables.tempEvent.eventVisibility == "Public"){
                eventVisibilityControl.selectedSegmentIndex = 0
            }
            else{
                eventVisibilityControl.selectedSegmentIndex = 1
            }
            eventDescription.text = globalVariables.tempEvent.eventDescription
            numOfHeads.text = globalVariables.tempEvent.numOfHead
            selectLocation.text =  globalVariables.tempEvent.location
           
            startTime.text = globalVariables.tempEvent.startTime
            endTime.text = globalVariables.tempEvent.endTime
        }
        if eventDescription.text.isEmpty {
            eventDescription.text = "Event Description, What to Bring, etc."
            eventDescription.textColor = UIColor.init(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func switched(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0){
            eventPrice = "Free"
            paymentField.isHidden = true
            tag.isHidden = true
            stripeSetup.isHidden = true
        }
        else{
            eventPrice = "Paid"
            paymentField.isHidden = false
            tag.isHidden = false
            stripeSetup.isHidden = false
        }
    }
    override func viewDidLoad() {
        tag.isHidden = true
        stripeSetup.layer.cornerRadius = 10
        stripeSetup.isHidden = true
        paymentField.isHidden = true
        paymentField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        paymentField.keyboardType = UIKeyboardType.numberPad
        UNUserNotificationCenter.current().delegate = self
        loader.hidesWhenStopped = true
        loader.center = view.center
        view.addSubview(loader)
        configureDatePicker()
        configureStartTimePicker()
        configureEndTimePicker()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.eventName.delegate = self
        self.eventType.delegate = self
        self.eventDescription.delegate = self
        self.numOfHeads.delegate = self
        ref = Database.database().reference()
        super.viewDidLoad()
        eventType.inputView = eventTypePicker
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector (doneEventClicked))
        toolBar.setItems([doneButton], animated: true)
        eventType.inputAccessoryView = toolBar
        eventTypePicker.delegate = self
        headsPicker.delegate = self
        startTimePicker.delegate = self
        endTimePicker.delegate = self
        numOfHeads.inputView = headsPicker
        let toolBar2 = UIToolbar()
        toolBar2.sizeToFit()
        let doneButton2 = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector (doneHeadsClicked))
        toolBar2.setItems([doneButton2], animated: true)
        numOfHeads.inputAccessoryView = toolBar2
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.eventName.frame.height))
        eventName.leftView = paddingView
        eventName.leftViewMode = UITextFieldViewMode.always
        let paddingView3 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.eventType.frame.height))
        eventType.leftView = paddingView3
        eventType.leftViewMode = UITextFieldViewMode.always
        let paddingView4 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.startTime.frame.height))
        startTime.leftView = paddingView4
        startTime.leftViewMode = UITextFieldViewMode.always
        let paddingView5 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.endTime.frame.height))
        endTime.leftView = paddingView5
        endTime.leftViewMode = UITextFieldViewMode.always
        let paddingView6 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.eventDate.frame.height))
        eventDate.leftView = paddingView6
        eventDate.leftViewMode = UITextFieldViewMode.always
        let paddingView7 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.numOfHeads.frame.height))
        numOfHeads.leftView = paddingView7
        numOfHeads.leftViewMode = UITextFieldViewMode.always
        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.selectLocation.frame.height))
        selectLocation.leftView = paddingView2
        selectLocation.leftViewMode = UITextFieldViewMode.always
    }
    //Functions
    func textViewDidBeginEditing(_ textView: UITextView) {
        eventDescription.text = ""
        eventDescription.textColor = UIColor.black
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        DispatchQueue.main.async() {
            self.overlayView.backgroundColor = UIColor.clear
        }
        chooseImage.alpha = 0
        cameraIcon.alpha = 0
        chooseImage2.alpha = 1
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            eventImage.image = selectedImage
            
        }
        dismiss(animated: true, completion: nil)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if eventDescription.text.isEmpty {
            eventDescription.text = "Event Description, What to Bring, etc."
            eventDescription.textColor = UIColor.init(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
        }
    }
    func doneEventClicked() {
        view.endEditing(true)
        let row = eventTypePicker.selectedRow(inComponent: 0)
        eventType.text = pickerData[row]
    }
    func doneStartTimeClicked() {
        view.endEditing(true)
        let row = startTimePicker.selectedRow(inComponent: 0)
        let row2 = startTimePicker.selectedRow(inComponent: 1)
        let row3 = startTimePicker.selectedRow(inComponent: 2)
        startTime.text = "\(hour[row]):\(minute[row2]) \(timeStamp[row3])"
    }
    func doneHeadsClicked() {
        view.endEditing(true)
        let row = headsPicker.selectedRow(inComponent: 0)
        numOfHeads.text = heads[row]
    }
    func doneEndTimeClicked() {
        view.endEditing(true)
        let row = endTimePicker.selectedRow(inComponent: 0)
        let row2 = endTimePicker.selectedRow(inComponent: 1)
        let row3 = endTimePicker.selectedRow(inComponent: 2)
        endTime.text = "\(hour[row]):\(minute[row2]) \(timeStamp[row3])"
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if(pickerView == startTimePicker || pickerView == endTimePicker){
            return 3
        }
        else{
            return 1
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == eventTypePicker){
            return pickerData.count
        }
        else if(pickerView == startTimePicker || pickerView == endTimePicker){
            if component == 0 {
                return hour.count
            }
            else if component == 1 {
                return minute.count
            }
            else{
                return timeStamp.count
            }
        }
        else{
            return heads.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == eventTypePicker){
            return pickerData[row]
        }
        else if(pickerView == startTimePicker || pickerView == endTimePicker){
            if component == 0 {
                return hour[row]
            }
            else if component == 1 {
                return minute[row]
            }
            else{
                return timeStamp[row]
            }
        }
        else{
            return heads[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == eventTypePicker){
            eventType.text = pickerData[row]
        }
        else if(pickerView == startTimePicker){
            let row = pickerView.selectedRow(inComponent: 0)
            let row2 = pickerView.selectedRow(inComponent: 1)
            let row3 = pickerView.selectedRow(inComponent: 2)
            startTime.text = "\(hour[row]):\(minute[row2]) \(timeStamp[row3])"
        }
        else if(pickerView == endTimePicker){
            let row = pickerView.selectedRow(inComponent: 0)
            let row2 = pickerView.selectedRow(inComponent: 1)
            let row3 = pickerView.selectedRow(inComponent: 2)
            endTime.text = "\(hour[row]):\(minute[row2]) \(timeStamp[row3])"
        }
        else{
            numOfHeads.text = heads[row]
        }
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    func configureDatePicker() {
        var components = DateComponents()
        components.year = -0
        let minDate = Calendar.current.date(byAdding: components, to: Date())
        datePicker.minimumDate = minDate
        eventDate.inputView = datePicker
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector (doneButtonClicked))
        toolBar.setItems([doneButton], animated: true)
        eventDate.inputAccessoryView = toolBar
        datePicker.datePickerMode = .date
    }
    func configureStartTimePicker() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector (doneStartTimeClicked))
        toolBar.setItems([doneButton], animated: true)
        startTime.inputView = startTimePicker
        startTime.inputAccessoryView = toolBar
    }
    func configureEndTimePicker() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector (doneEndTimeClicked))
        toolBar.setItems([doneButton], animated: true)
        endTime.inputView = endTimePicker
        endTime.inputAccessoryView = toolBar
    }
    func doneButtonClicked() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        view.endEditing(true)
        eventDate.text =  dateFormatter.string(from: datePicker.date)
    }
}
extension HatchViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        eventLocation = "\(place.name)"
        eventAddress = "\(place.formattedAddress!)"
        longitude = place.coordinate.longitude
        latitude = place.coordinate.latitude
        selectLocation.text = eventLocation!
        dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Swift.Error) {
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

