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
struct global {
    static var eventsHosted = [Event]()
    static var yourEvents = [Event]()
}
class MoreViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource{
    var y = 0.0
    var counter = 0
    let overlay = UIView()
    let loader = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var numOfEventsHatched: UILabel!
    @IBOutlet weak var numOfAttendedEvents: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noEventsFound: UILabel!
    @IBOutlet weak var bio: UITextView!
    @IBOutlet weak var numberOfInterests: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var picLoader: UIActivityIndicatorView!
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
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0){
            if(global.eventsHosted.count == 0){
                noEventsFound.alpha = 1
            }
            else{
                noEventsFound.alpha = 0
            }
            numberOfInterests.alpha = 0
            scrollView.alpha = 0
            tableView.alpha = 1
            tableView.reloadData()
        }
        else if(sender.selectedSegmentIndex == 1){
            noEventsFound.alpha = 0
            numberOfInterests.alpha = 1
            scrollView.alpha = 1
            tableView.alpha = 0
        }
        else{
            if(global.yourEvents.count == 0){
                noEventsFound.alpha = 1
            }
            else{
                noEventsFound.alpha = 0
            }
            numberOfInterests.alpha = 0
            scrollView.alpha = 0
            tableView.alpha = 1
            tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        globalEvent.selectedRow = indexPath.row
        if(segmentedControl.selectedSegmentIndex == 0){
            variables.check = true
            variables.attended = false
        }
        else if(segmentedControl.selectedSegmentIndex == 2){
            variables.attended = true
            variables.check = false
        }
        performSegue(withIdentifier: "showInfo", sender: self)
    }
    func loadInterests() {
        var i = 0
        var x = 10.0
        y = 30.0
        for interests in globalEvent.interestsArr {
            let width = Double(interests.count) * 10
            if(x + width > Double(view.frame.width)){
                y += 50.0
                x = 10.0
            }
            let lblNew = UILabel(frame: CGRect(x: x, y: y, width: width, height: 40.0))
            lblNew.font = UIFont(name: "Lato-Light", size: 14)
            lblNew.backgroundColor = UIColor.white
            lblNew.textAlignment = .center
            lblNew.text = interests
            lblNew.tag = i
            lblNew.layer.borderColor = UIColor.init(red: 101/255, green: 98/255, blue: 190/255, alpha: 1).cgColor
            lblNew.layer.cornerRadius = 10
            lblNew.clipsToBounds = true
            lblNew.layer.borderWidth = 0.5
            lblNew.textColor = UIColor.init(red: 101/255, green: 98/255, blue: 190/255, alpha: 1)
            scrollView.addSubview(lblNew)
            i += 1
            x += width + 10
        }
        scrollView.contentSize = CGSize(width: 375, height: y + 80)
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(segmentedControl.selectedSegmentIndex == 2)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventsHatchedTableViewCell
            cell.eventName.text = global.yourEvents[indexPath.row].eventName
            cell.eventLocation.text = global.yourEvents[indexPath.row].location
            if(global.yourEvents[indexPath.row].interested == false){
                let d1 = DateFormatter()
                d1.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                let date = d1.date(from: global.yourEvents[indexPath.row].codedDate!)
                if(date!.timeIntervalSinceNow < 0){
                    cell.peopleAttended.text = "Attended"
                }
                else{
                    cell.peopleAttended.text = "Going"
                }
            }
            else{
                cell.peopleAttended.text = "Interested"
            }
            let url = URL(string: global.yourEvents[indexPath.row].eventImage!)
            URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                if(error == nil)
                {
                    DispatchQueue.main.async {
                        cell.eventImage.image = UIImage(data: data!)
                        cell.activityIndicator.stopAnimating()
                    }
                }
                
            }).resume()
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventsHatchedTableViewCell
            cell.eventName.text = global.eventsHosted[indexPath.row].eventName
            cell.eventLocation.text = global.eventsHosted[indexPath.row].location
            let d1 = DateFormatter()
            d1.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            let date = d1.date(from: global.eventsHosted[indexPath.row].codedDate!)
            if(date!.timeIntervalSinceNow < 0){
                cell.peopleAttended.text = "\(global.eventsHosted[indexPath.row].usersGoing.count) Users Attended"
            }
            else{
                cell.peopleAttended.text = "\(global.eventsHosted[indexPath.row].usersGoing.count) Users Going"
            }
            let url = URL(string: global.eventsHosted[indexPath.row].eventImage!)
            URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                if(error == nil)
                {
                    DispatchQueue.main.async {
                        cell.eventImage.image = UIImage(data: data!)
                        cell.activityIndicator.stopAnimating()
                    }
                }
                
            }).resume()
            return cell
        }
    }
    func fetchYourEvents() {
        counter = 0
        global.yourEvents = []
        Database.database().reference().child("Events").observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as! [String: AnyObject]?
            {
                let event = Event()
                for events in snapshot.children.allObjects as! [DataSnapshot]{
                    if(events.key == "Interested Users"){
                        
                            for users in events.children.allObjects as! [DataSnapshot]{
                                if(users.value as? String == Auth.auth().currentUser?.uid){
                                    event.interested = true
                                    event.eventName = dict["Event Name"] as? String
                                    event.codedDate = dict["Coded Date"] as? String
                                    event.location = dict["Event Location"] as? String
                                    event.eventImage = dict["Event Image"] as? String
                                    var usersGoing = 0
                                    var numOfHead = 0
                                    event.eventAddress = dict["Event Address"] as? String
                                    event.startTime = dict["Start Time"] as? String
                                    event.endTime = dict["End Time"] as? String
                                    event.eventType = dict["Event Type"] as? String
                                    event.eventVisibility = dict["Accessibility"] as? String
                                    event.numOfHead = dict["Number of Heads"] as? String
                                    if(dict["Number of Heads"] as! String == "Unlimited"){
                                        numOfHead = Int.max
                                    }
                                    else{
                                        numOfHead = Int(dict["Number of Heads"] as! String)!
                                    }
                                    event.eventDescription = dict["Event Description"] as? String
                                    event.eventDate = dict["Date"] as? String
                                    event.uuid = dict["Event UUID"] as? String
                                    event.long = dict["Longitude"] as? Double
                                    event.lat = dict["Latitude"] as? Double
                                    event.host = dict["Host"] as? String
                                    for events in snapshot.children.allObjects as! [DataSnapshot]{
                                        if(events.key == "Interested Users"){
                                            for users in events.children.allObjects as! [DataSnapshot]{
                                                event.interestedUsers.append(users.value as! String)
                                            }
                                        }
                                        else if(events.key == "Users Going"){
                                            for users in events.children.allObjects as! [DataSnapshot]{
                                                event.usersGoing.append(users.value as! String)
                                            }
                                            usersGoing = event.usersGoing.count
                                        }
                                        else if(events.key == "Requested Users"){
                                            for users in events.children.allObjects as! [DataSnapshot]{
                                                event.requestedUsers.append(users.value as! String)
                                            }
                                        }
                                    }
                                    event.numOfHead = "\(numOfHead - usersGoing)"
                                    let d1 = DateFormatter()
                                    d1.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                                    let date = d1.date(from: event.codedDate!)
                                    if(date!.timeIntervalSinceNow < 0){
                                        self.counter += 1
                                    }
                                    global.yourEvents.append(event)
                                    global.yourEvents.sort(by: { $0.codedDate!.compare($1.codedDate!) == .orderedDescending })
                                }
                            }
                        
                    }
                    if(events.key == "Users Going"){
                        for users in events.children.allObjects as! [DataSnapshot]{
                            if(users.value as? String == Auth.auth().currentUser?.uid){
                                event.interested = false
                                event.eventName = dict["Event Name"] as? String
                                event.codedDate = dict["Coded Date"] as? String
                                event.location = dict["Event Location"] as? String
                                event.eventImage = dict["Event Image"] as? String
                                var usersGoing = 0
                                var numOfHead = 0
                                event.eventAddress = dict["Event Address"] as? String
                                event.startTime = dict["Start Time"] as? String
                                event.endTime = dict["End Time"] as? String
                                event.eventType = dict["Event Type"] as? String
                                event.eventVisibility = dict["Accessibility"] as? String
                                event.numOfHead = dict["Number of Heads"] as? String
                                if(dict["Number of Heads"] as! String == "Unlimited"){
                                    numOfHead = Int.max
                                }
                                else{
                                    numOfHead = Int(dict["Number of Heads"] as! String)!
                                }
                                event.eventDescription = dict["Event Description"] as? String
                                event.eventDate = dict["Date"] as? String
                                event.uuid = dict["Event UUID"] as? String
                                event.long = dict["Longitude"] as? Double
                                event.lat = dict["Latitude"] as? Double
                                event.host = dict["Host"] as? String
                                for events in snapshot.children.allObjects as! [DataSnapshot]{
                                    if(events.key == "Interested Users"){
                                         event.interestedUsers = []
                                        for users in events.children.allObjects as! [DataSnapshot]{
                                            event.interestedUsers.append(users.value as! String)
                                        }
                                    }
                                    else if(events.key == "Users Going"){
                                        event.usersGoing = []
                                        for users in events.children.allObjects as! [DataSnapshot]{
                                            event.usersGoing.append(users.value as! String)
                                        }
                                        usersGoing = event.usersGoing.count
                                    }
                                    else if(events.key == "Requested Users"){
                                        event.requestedUsers = []
                                        for users in events.children.allObjects as! [DataSnapshot]{
                                            event.requestedUsers.append(users.value as! String)
                                        }
                                    }
                                }
                                event.numOfHead = "\(numOfHead - usersGoing)"
                                let d1 = DateFormatter()
                                d1.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                                let date = d1.date(from: event.codedDate!)
                                if(date!.timeIntervalSinceNow < 0){
                                    self.counter += 1
                                }
                                if(!global.yourEvents.contains(event)){
                                    global.yourEvents.append(event)
                                    global.yourEvents.sort(by: { $0.codedDate!.compare($1.codedDate!) == .orderedDescending })
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    func fetchEvents() {
            global.eventsHosted = []
            Database.database().reference().child("Events").observe(.childAdded, with: { (snapshot) in
                if let dict = snapshot.value as! [String: AnyObject]?
                {
                    if(dict["Host"] as? String == Auth.auth().currentUser?.uid){
                        let event = Event()
                        event.eventName = dict["Event Name"] as? String
                        event.codedDate = dict["Coded Date"] as? String
                        event.location = dict["Event Location"] as? String
                        event.eventImage = dict["Event Image"] as? String
                        var usersGoing = 0
                        var numOfHead = 0
                        event.eventAddress = dict["Event Address"] as? String
                        event.startTime = dict["Start Time"] as? String
                        event.endTime = dict["End Time"] as? String
                        event.eventType = dict["Event Type"] as? String
                        event.eventVisibility = dict["Accessibility"] as? String
                        event.numOfHead = dict["Number of Heads"] as? String
                        if(dict["Number of Heads"] as! String == "Unlimited"){
                            numOfHead = Int.max
                        }
                        else{
                            numOfHead = Int(dict["Number of Heads"] as! String)!
                        }
                        event.eventDescription = dict["Event Description"] as? String
                        event.eventDate = dict["Date"] as? String
                        event.uuid = dict["Event UUID"] as? String
                        event.long = dict["Longitude"] as? Double
                        event.lat = dict["Latitude"] as? Double
                        event.host = dict["Host"] as? String
                        for events in snapshot.children.allObjects as! [DataSnapshot]{
                            if(events.key == "Interested Users"){
                                for users in events.children.allObjects as! [DataSnapshot]{
                                    event.interestedUsers.append(users.value as! String)
                                }
                            }
                            else if(events.key == "Users Going"){
                                for users in events.children.allObjects as! [DataSnapshot]{
                                    event.usersGoing.append(users.value as! String)
                                }
                                usersGoing = event.usersGoing.count
                            }
                            else if(events.key == "Requested Users"){
                                for users in events.children.allObjects as! [DataSnapshot]{
                                    event.requestedUsers.append(users.value as! String)
                                }
                            }
                        }
                        event.numOfHead = "\(numOfHead - usersGoing)"
                        global.eventsHosted.append(event)
                        global.eventsHosted.sort(by: { $0.codedDate!.compare($1.codedDate!) == .orderedDescending })
                    }
                }
            })
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(segmentedControl.selectedSegmentIndex == 2){
            return global.yourEvents.count
        }
        else{
            numOfAttendedEvents.text = "\(counter) Events Attended"
            numOfEventsHatched.text = "\(global.eventsHosted.count) Events Hatched"
            return global.eventsHosted.count
        }
    }
    override func viewDidLayoutSubviews() {
        scrollView.isScrollEnabled = true
    }
    func fetchInterests() {
       var count: UInt?
       globalEvent.interestsArr = []
        numberOfInterests.tag = 30
        for view in scrollView.subviews{
            if(view.tag != 30){
            view.removeFromSuperview()
            }
        }
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).observe(.childAdded, with: { (snapshot) in
            if(snapshot.key == "Interests"){
                count = snapshot.childrenCount
                for child in snapshot.children.allObjects as! [DataSnapshot]{
                    globalEvent.interestsArr.append(child.value as! String)
                }
            }
            if(UInt(globalEvent.interestsArr.count) == count){
                self.numberOfInterests.text = "\(globalEvent.interestsArr.count) Interests"
                self.loadInterests()
            }
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        //variables.check = false
        //variables.attended = false
        fetchEvents()
        fetchYourEvents()
        fetchInterests()
        let ref = Database.database().reference()
        var firstName = ""
        var lastName = ""
        let uid = Auth.auth().currentUser?.uid
        ref.child("Users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot)
            in
            if let dict = snapshot.value as? [String: AnyObject]
            {
                firstName = dict["First Name"] as! String
                lastName = dict["Last Name"] as! String
                self.navigationController?.navigationBar.topItem?.title = "\(firstName) \(lastName)"
                self.userName.text! = dict["Username"] as! String
                if(dict["Bio"] as? String == nil){
                    self.bio.text = "Let others know what you're about! Add a bio :)"
                }
                else{
                    self.bio.text = dict["Bio"] as? String
                }
                
            }
        })
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //variables.check = false
        //variables.attended = false
        noEventsFound.alpha = 0
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Lato-Light", size: 20)!, NSForegroundColorAttributeName : UIColor.white
        ]
        tableView.alpha = 0
        scrollView.alpha = 1
        scrollView.backgroundColor = UIColor.white
        segmentedControl.selectedSegmentIndex = 1
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        ref.child("Users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot)
            in
            if let dict = snapshot.value as? [String: AnyObject]
            {
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
        borderView.layer.cornerRadius = borderView.frame.height / 2
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        borderView.backgroundColor = UIColor.white
        picLoader.hidesWhenStopped = true
        picLoader.startAnimating()
        view.addSubview(loader)
        profilePicture.clipsToBounds = true
        overlay.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let gradient = CAGradientLayer()
        gradient.frame = overlay.bounds
        gradient.colors = [
            UIColor(red: 198/255, green: 152/255, blue: 201/255, alpha: 1).cgColor, UIColor(red: 129/255, green: 151/255, blue: 229/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:0)
        self.overlay.layer.addSublayer(gradient)
        let gradientLayer = CAGradientLayer()
        var updatedFrame = self.navigationController!.navigationBar.bounds
        updatedFrame.size.height += 20
        gradientLayer.frame = updatedFrame
        gradientLayer.colors = [UIColor(red: 198/255, green: 152/255, blue: 201/255, alpha: 1).cgColor, UIColor(red: 129/255, green: 151/255, blue: 229/255, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.navigationController!.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
        let h = view.frame.height / 2 * 0.40
        let i = view.frame.height / 2 * 0.10
        let p1 = view.bounds.origin
        let p2 = CGPoint(x:p1.x + view.frame.width, y:p1.y)
        let p3 = CGPoint(x:p2.x, y:p2.y + h)
        let p4 = CGPoint(x:p1.x, y:p2.y + i)
        let p5 = CGPoint(x:p1.x, y:p1.y)
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: p2)
        path.addLine(to: p3)
        path.addLine(to: p4)
        path.addLine(to: p5)
        path.close()
        let mask = CAShapeLayer()
        mask.frame = overlay.bounds
        mask.path = path.cgPath
        overlay.layer.mask = mask
        view.addSubview(overlay)
        view.sendSubview(toBack: overlay)
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
