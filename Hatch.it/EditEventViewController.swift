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
import UserNotifications

class EditEventViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UNUserNotificationCenterDelegate {
    //IBOutlets
    @IBOutlet weak var chooseImage2: UIButton!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventType: UITextField!
    @IBOutlet weak var numOfHeads: UITextField!
    @IBOutlet weak var eventDate: UITextField!
    @IBOutlet weak var selectLocation: UITextField!
    @IBOutlet weak var chooseImage: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var cameraIcon: UIImageView!
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
    @IBAction func deleteEvent(_ sender: UIButton) {
        var uuid = ""
        if(variables.check){
            uuid = global.eventsHosted[globalEvent.selectedRow].uuid!
        }
        else if(variables.attended){
            uuid = global.yourEvents[globalEvent.selectedRow].uuid!
        }
        else{
            if(globalEvent.searching){
                uuid = globalEvent.filteredEventList[globalEvent.selectedRow].uuid!
            }
            else{
                uuid = globalEvent.eventList[globalEvent.selectedRow].uuid!
            }
        }
        Database.database().reference().child("Events").child(uuid).removeValue()
        Database.database().reference().child("Notifications").child((Auth.auth().currentUser?.uid)!).child(uuid).removeValue()
        Storage.storage().reference().child("Event Images").child(uuid).delete(completion: nil)
        let alert = UIAlertController(title: "Success", message: "Your Event Has Been Deleted", preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        eventName.text = ""
        eventType.text = ""
        eventDescription.text = ""
        numOfHeads.text = ""
        eventDate.text = ""
        selectLocation.text = ""
        startTime.text = ""
        endTime.text = ""
        eventImage.image = nil
        chooseImage2.alpha = 0
        doneButton.alpha = 0
        overlayView.backgroundColor = UIColor.init(red: 188/255, green: 188/255, blue: 189/255, alpha: 0.8)
        loader.stopAnimating()
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
    @IBAction func createEvent(_ sender: UIButton) {
        loader.startAnimating()
        if(eventName.text! == "" || eventType.text! == "" || eventDescription.text! == "" || numOfHeads.text! == "" || eventDate.text! == "" || startTime.text! == "" || endTime.text! == ""){
            loader.stopAnimating()
            let alert = UIAlertController(title: "Error", message: "Fields Cannot be Left Blank", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            if(selectLocation.text == "" || selectLocation.text == nil){
                loader.stopAnimating()
                let alert = UIAlertController(title: "Error", message: "Choose an Event Location", preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
            }
            else{
                if(variables.check){
                    uuid = global.eventsHosted[globalEvent.selectedRow].uuid!
                }
                else if(variables.attended){
                    uuid = global.yourEvents[globalEvent.selectedRow].uuid!
                }
                else{
                    if(globalEvent.searching){
                        uuid = globalEvent.filteredEventList[globalEvent.selectedRow].uuid!
                    }
                    else{
                        uuid = globalEvent.eventList[globalEvent.selectedRow].uuid!
                    }
                }
                let storage = Storage.storage()
                let uploadData = UIImageJPEGRepresentation(self.eventImage.image!, 0.0)
                let storageRef = storage.reference().child("Event Images").child(uuid)
                storageRef.putData(uploadData!).observe(.success) { (snapshot) in
                    self.downloadURL = snapshot.metadata?.downloadURL()?.absoluteString
                    self.ref.child("Events").child(self.uuid).updateChildValues(["Event Image": self.downloadURL as Any])
                }
                let dateFormatter = DateFormatter()
                let reference = Database.database().reference().child("Events").child(uuid)
                dateFormatter.dateFormat = "MMMM dd, yyyy 'at' h:mm a"
                let string = eventDate.text! + " at " + endTime.text!
                let finalDate = dateFormatter.date(from: string)
                reference.updateChildValues(["Event Name": self.eventName.text!])
                reference.updateChildValues(["Event Type": self.eventType.text!])
                reference.updateChildValues(["Date": self.eventDate.text!])
                reference.updateChildValues(["Coded Date": "\(finalDate!)"])
                reference.updateChildValues(["Accessibility": eventVisibility])
                reference.updateChildValues(["Event Description": self.eventDescription.text!])
                reference.updateChildValues(["Number of Heads": self.numOfHeads.text!])
                reference.updateChildValues(["Event UUID": uuid])
                reference.updateChildValues(["Start Time": startTime.text!])
                reference.updateChildValues(["End Time": endTime.text!])
                reference.updateChildValues(["Host": Auth.auth().currentUser!.uid])
                if(eventLocation != nil){
                    reference.updateChildValues(["Event Location": eventLocation!])
                    reference.updateChildValues(["Event Address": eventAddress!])
                    reference.updateChildValues(["Longitude": longitude])
                    reference.updateChildValues(["Latitude": latitude])
                }
                let event = Event()
                event.eventName = self.eventName.text!
                event.eventType = self.eventType.text!
                event.eventDate = self.eventDate.text!
                event.codedDate = "\(finalDate!)"
                event.eventVisibility = eventVisibility
                event.eventDescription = self.eventDescription.text!
                event.numOfHead = self.numOfHeads.text!
                event.location = ""
                event.long = longitude
                event.lat = latitude
                event.uuid = uuid
                event.eventImage = downloadURL
                event.startTime = startTime.text!
                event.endTime = endTime.text!
                event.host = Auth.auth().currentUser?.uid
                globalEvent.eventList.append(event)
                locationPicked = false
                globalVariables.event.eventName = eventName.text
                globalVariables.event.eventVisibility = eventVisibility
                globalVariables.event.location = "eventLocation!"
                globalVariables.event.eventDate = eventDate.text
                globalVariables.event.eventDescription = eventDescription.text
                globalVariables.event.numOfHead = numOfHeads.text
                globalVariables.event.eventImage = downloadURL
                overlayView.backgroundColor = UIColor.init(red: 188/255, green: 188/255, blue: 189/255, alpha: 0.8)
                loader.stopAnimating()
                let alert = UIAlertController(title: "Success", message: "Your Event Has Been Updated", preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
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
        scrollView.contentSize = CGSize(width: 375, height: 950)
    }
    override func viewWillAppear(_ animated: Bool) {
        if eventDescription.text.isEmpty {
            eventDescription.text = "Event Description, What to Bring, etc."
            eventDescription.textColor = UIColor.init(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidLoad() {
        navigationController?.navigationBar.topItem?.title = "Edit Event"
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
        if(variables.check)
        {
            Database.database().reference().child("Events").child(global.eventsHosted[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                if(snapshot.key == "Event Name"){
                    self.eventName.text = snapshot.value as? String
                }
                if(snapshot.key == "Event Type"){
                    self.eventType.text = snapshot.value as? String
                }
                if(snapshot.key == "Event Description"){
                    self.eventDescription.text = snapshot.value as? String
                    self.eventDescription.textColor = UIColor.black
                }
                if(snapshot.key == "Date"){
                    self.eventDate.text = snapshot.value as? String
                }
                if(snapshot.key == "Start Time"){
                    self.startTime.text = snapshot.value as? String
                }
                if(snapshot.key == "End Time"){
                    self.endTime.text = snapshot.value as? String
                }
                if(snapshot.key == "Event Location"){
                    self.selectLocation.text = snapshot.value as? String
                }
                if(snapshot.key == "Accessibility"){
                    if(snapshot.value as? String == "Public"){
                        self.eventVisibilityControl.selectedSegmentIndex = 0
                    }
                    else{
                        self.eventVisibilityControl.selectedSegmentIndex = 1
                    }
                }
                if(snapshot.key == "Number of Heads"){
                    self.numOfHeads.text = snapshot.value as? String
                }
                if(snapshot.key == "Event Image"){
                    let url = URL(string: snapshot.value as! String)
                    self.chooseImage.alpha = 0
                    self.cameraIcon.alpha = 0
                    self.chooseImage2.alpha = 1
                    URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                        if(error == nil)
                        {
                            DispatchQueue.main.async {
                                self.eventImage.image = UIImage(data: data!)
                            }
                        }
                        
                    }).resume()
                }
            })
        }
        else if(variables.attended){
            Database.database().reference().child("Events").child(global.yourEvents[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                if(snapshot.key == "Event Name"){
                    self.eventName.text = snapshot.value as? String
                }
                if(snapshot.key == "Event Type"){
                    self.eventType.text = snapshot.value as? String
                }
                if(snapshot.key == "Event Description"){
                    self.eventDescription.text = snapshot.value as? String
                    self.eventDescription.textColor = UIColor.black
                }
                if(snapshot.key == "Date"){
                    self.eventDate.text = snapshot.value as? String
                }
                if(snapshot.key == "Start Time"){
                    self.startTime.text = snapshot.value as? String
                }
                if(snapshot.key == "End Time"){
                    self.endTime.text = snapshot.value as? String
                }
                if(snapshot.key == "Event Location"){
                    self.selectLocation.text = snapshot.value as? String
                }
                if(snapshot.key == "Accessibility"){
                    if(snapshot.value as? String == "Public"){
                        self.eventVisibilityControl.selectedSegmentIndex = 0
                    }
                    else{
                        self.eventVisibilityControl.selectedSegmentIndex = 1
                    }
                }
                if(snapshot.key == "Number of Heads"){
                    self.numOfHeads.text = snapshot.value as? String
                }
                if(snapshot.key == "Event Image"){
                    let url = URL(string: snapshot.value as! String)
                    self.chooseImage.alpha = 0
                    self.cameraIcon.alpha = 0
                    self.chooseImage2.alpha = 1
                    URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                        if(error == nil)
                        {
                            DispatchQueue.main.async {
                                self.eventImage.image = UIImage(data: data!)
                            }
                        }
                        
                    }).resume()
                }
            })
        }
        else{
            if(globalEvent.searching){
                Database.database().reference().child("Events").child(globalEvent.filteredEventList[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                    if(snapshot.key == "Event Name"){
                        self.eventName.text = snapshot.value as? String
                    }
                    if(snapshot.key == "Event Type"){
                        self.eventType.text = snapshot.value as? String
                    }
                    if(snapshot.key == "Event Description"){
                        self.eventDescription.text = snapshot.value as? String
                        self.eventDescription.textColor = UIColor.black
                    }
                    if(snapshot.key == "Date"){
                        self.eventDate.text = snapshot.value as? String
                    }
                    if(snapshot.key == "Start Time"){
                        self.startTime.text = snapshot.value as? String
                    }
                    if(snapshot.key == "End Time"){
                        self.endTime.text = snapshot.value as? String
                    }
                    if(snapshot.key == "Event Location"){
                        self.selectLocation.text = snapshot.value as? String
                    }
                    if(snapshot.key == "Accessibility"){
                        if(snapshot.value as? String == "Public"){
                            self.eventVisibilityControl.selectedSegmentIndex = 0
                        }
                        else{
                            self.eventVisibilityControl.selectedSegmentIndex = 1
                        }
                    }
                    if(snapshot.key == "Number of Heads"){
                        self.numOfHeads.text = snapshot.value as? String
                    }
                    if(snapshot.key == "Event Image"){
                        let url = URL(string: snapshot.value as! String)
                        self.chooseImage.alpha = 0
                        self.cameraIcon.alpha = 0
                        self.chooseImage2.alpha = 1
                        URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                            if(error == nil)
                            {
                                DispatchQueue.main.async {
                                    self.eventImage.image = UIImage(data: data!)
                                }
                            }
                            
                        }).resume()
                    }
                })
            }
            else{
                Database.database().reference().child("Events").child(globalEvent.eventList[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                    if(snapshot.key == "Event Name"){
                        self.eventName.text = snapshot.value as? String
                    }
                    if(snapshot.key == "Event Type"){
                        self.eventType.text = snapshot.value as? String
                    }
                    if(snapshot.key == "Event Description"){
                        self.eventDescription.text = snapshot.value as? String
                        self.eventDescription.textColor = UIColor.black
                    }
                    if(snapshot.key == "Date"){
                        self.eventDate.text = snapshot.value as? String
                    }
                    if(snapshot.key == "Start Time"){
                        self.startTime.text = snapshot.value as? String
                    }
                    if(snapshot.key == "End Time"){
                        self.endTime.text = snapshot.value as? String
                    }
                    if(snapshot.key == "Event Location"){
                        self.selectLocation.text = snapshot.value as? String
                    }
                    if(snapshot.key == "Accessibility"){
                        if(snapshot.value as? String == "Public"){
                            self.eventVisibilityControl.selectedSegmentIndex = 0
                        }
                        else{
                            self.eventVisibilityControl.selectedSegmentIndex = 1
                        }
                    }
                    if(snapshot.key == "Number of Heads"){
                        self.numOfHeads.text = snapshot.value as? String
                    }
                    if(snapshot.key == "Event Image"){
                        let url = URL(string: snapshot.value as! String)
                        self.chooseImage.alpha = 0
                        self.cameraIcon.alpha = 0
                        self.chooseImage2.alpha = 1
                        URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                            if(error == nil)
                            {
                                DispatchQueue.main.async {
                                    self.eventImage.image = UIImage(data: data!)
                                }
                            }
                            
                        }).resume()
                    }
                })
            }
        }
        
        Database.database().reference().child("Events").child(global.eventsHosted[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
            if(snapshot.key == "Event Name"){
                self.eventName.text = snapshot.value as? String
            }
            if(snapshot.key == "Event Type"){
                self.eventType.text = snapshot.value as? String
            }
            if(snapshot.key == "Event Description"){
                self.eventDescription.text = snapshot.value as? String
                self.eventDescription.textColor = UIColor.black
            }
            if(snapshot.key == "Date"){
                self.eventDate.text = snapshot.value as? String
            }
            if(snapshot.key == "Start Time"){
                self.startTime.text = snapshot.value as? String
            }
            if(snapshot.key == "End Time"){
                self.endTime.text = snapshot.value as? String
            }
            if(snapshot.key == "Event Location"){
                self.selectLocation.text = snapshot.value as? String
            }
            if(snapshot.key == "Accessibility"){
                if(snapshot.value as? String == "Public"){
                    self.eventVisibilityControl.selectedSegmentIndex = 0
                }
                else{
                    self.eventVisibilityControl.selectedSegmentIndex = 1
                }
            }
            if(snapshot.key == "Number of Heads"){
                self.numOfHeads.text = snapshot.value as? String
            }
            if(snapshot.key == "Event Image"){
                let url = URL(string: snapshot.value as! String)
                self.chooseImage.alpha = 0
                self.cameraIcon.alpha = 0
                self.chooseImage2.alpha = 1
                URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                    if(error == nil)
                    {
                        DispatchQueue.main.async {
                            self.eventImage.image = UIImage(data: data!)
                        }
                    }
                    
                }).resume()
            }
        })
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
extension EditEventViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        eventLocation = "\(place.name)"
        eventAddress = "\(place.formattedAddress!)"
        longitude = place.coordinate.longitude
        latitude = place.coordinate.latitude
        selectLocation.text = eventLocation!
        dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
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
