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
//Global Variables
struct globalVariables {
    static var event = Event()
    static var notification = [Notifiction]()
}
class HatchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
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
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    @IBOutlet weak var eventVisibilityControl: UISegmentedControl!
    //Variables and Constants
    var ref: DatabaseReference!
    let eventTypePicker = UIPickerView()
    let startTimePicker = UIPickerView()
    let endTimePicker = UIPickerView()
    let headsPicker = UIPickerView()
    var userLocation: String?
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
    @IBAction func chooseLocation(_ sender: UIButton) {
        locationPicked = true
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    @IBAction func createEvent(_ sender: UIButton) {
        uuid = NSUUID().uuidString
        if(eventName.text! == "" || eventType.text! == "" || eventDescription.text! == "" || numOfHeads.text! == "" || eventDate.text! == "" || startTime.text! == "" || endTime.text! == ""){
            let alert = UIAlertController(title: "Error", message: "Fields Cannot be Left Blank", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        if(locationPicked == false){
            let alert = UIAlertController(title: "Error", message: "Please Choose A Location", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        if(picturePicked == false){
            let alert = UIAlertController(title: "Error", message: "Please Choose an Event Image", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else if(locationPicked == true){
            let info = [
                "Event Name":  self.eventName.text!,
                "Event Type": self.eventType.text!,
                "Date": self.eventDate.text!,
                "Accessibility": eventVisibility,
                "Event Description": self.eventDescription.text!,
                "Number of Heads": self.numOfHeads.text!,
                "Event Location": userLocation!,
                "Longitude": longitude,
                "Latitude": latitude,
                "Event UUID": uuid,
                "Event Image": downloadURL,
                "Start Time": startTime.text!,
                "End Time": endTime.text!
                ] as [String : Any?]
            ref.child("Events").child(uuid).setValue(info)
            locationPicked = false
            globalVariables.event.eventName = eventName.text
            globalVariables.event.eventVisibility = eventVisibility
            globalVariables.event.location = userLocation!
            globalVariables.event.eventDate = eventDate.text
            globalVariables.event.eventDescription = eventDescription.text
            globalVariables.event.numOfHead = numOfHeads.text
            globalVariables.event.eventImage = downloadURL
            eventName.text = ""
            eventType.text = ""
            eventDescription.text = ""
            numOfHeads.text = ""
            eventDate.text = ""
            selectLocation.text = ""
            startTime.text = ""
            endTime.text = ""
            eventImage.image = #imageLiteral(resourceName: "NYC")
            chooseImage2.alpha = 0
            chooseImage.alpha = 1
            cameraIcon.alpha = 1
            overlayView.backgroundColor = UIColor.init(red: 188/255, green: 188/255, blue: 189/255, alpha: 0.8)
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
            eventDescription.text = "Event Description"
            eventDescription.textColor = UIColor.init(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidLoad() {
        configureDatePicker()
        configureTimePicker()
        chooseImage.layer.cornerRadius = 10
        chooseImage.layer.borderWidth = 2
        chooseImage.layer.borderColor = UIColor.init(red: 239/255, green: 59/255, blue: 51/255, alpha: 1).cgColor
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
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector (doneClicked))
        toolBar.setItems([doneButton], animated: true)
        eventType.inputAccessoryView = toolBar
        eventTypePicker.delegate = self
        headsPicker.delegate = self
        startTimePicker.delegate = self
        endTimePicker.delegate = self
        numOfHeads.inputView = headsPicker
        numOfHeads.inputAccessoryView = toolBar
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
            let storage = Storage.storage()
            let uploadData = UIImagePNGRepresentation(self.eventImage.image!)
            let storageRef = storage.reference().child("Event Images/\(uuid)/eventImage.png")
            storageRef.putData(uploadData!).observe(.success) { (snapshot) in
                self.downloadURL = snapshot.metadata?.downloadURL()?.absoluteString
            }
        }
        dismiss(animated: true, completion: nil)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if eventDescription.text.isEmpty {
            eventDescription.text = "Event Description"
            eventDescription.textColor = UIColor.init(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
        }
    }
    func doneClicked() {
        view.endEditing(true)
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
    func configureTimePicker() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector (dismissKeyboard))
        toolBar.setItems([doneButton], animated: true)
        startTime.inputView = startTimePicker
        endTime.inputView = endTimePicker
        startTime.inputAccessoryView = toolBar
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
//Google AutoComplete
extension HatchViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        userLocation = "\(place.name)"
        longitude = place.coordinate.longitude
        latitude = place.coordinate.latitude
        selectLocation.text = userLocation!
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

