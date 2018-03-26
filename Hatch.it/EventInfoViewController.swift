//
//  EventInfoViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 11/28/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit
import AudioToolbox
import Firebase
import Mapbox
import CoreLocation
import MessageUI
import MapKit
import Stripe
import AURUnlockSlider
import Social
struct variables{
    static var approved = false
    static var check = false
    static var attended = false
    static var event = [Event]()
    static var pay = false
    static var uuid = ""
    static var cleared = false
    static var link = false
    static var chain = [Event]()
}
class EventInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MGLMapViewDelegate, MFMessageComposeViewControllerDelegate, SlideButtonDelegate, STPPaymentCardTextFieldDelegate {

    var dragPoint = UIView()
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    let paymentTextField = STPPaymentCardTextField()
    var currentGradient: Int = 0
    let gradientOne = UIColor(red: 69/255, green: 104/255, blue: 220/255, alpha: 1).cgColor
    let gradientTwo = UIColor(red: 176/255, green: 106/255, blue: 179/255, alpha: 1).cgColor
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var editEvent: UIButton!
    @IBAction func resetButton(_ sender: UIButton) {
        if(!variables.pay){
        slidingButton.reset()
        resetButton.alpha = 0
        if(variables.check){
            if(global.eventsHosted[globalEvent.selectedRow].eventVisibility == "Private"){
                //slidingButton.buttonText = "Request"
                slidingButton.buttonLabel.text = "Request"
                Database.database().reference().child("Events").child(global.eventsHosted[globalEvent.selectedRow].uuid!).child("Requested Users").observe(.childAdded, with: { (snapshot) in
                    if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                        Database.database().reference().child("Events").child(global.eventsHosted[globalEvent.selectedRow].uuid!).child("Requested Users").child(snapshot.key).removeValue()
                        Database.database().reference().child("Events").child(global.eventsHosted[globalEvent.selectedRow].uuid!).child("Requested Users").removeAllObservers()
                    }
                })
                Database.database().reference().child("Events").observe(.childAdded, with: { (snapshot) in
                    for child in snapshot.children.allObjects as! [DataSnapshot]{
                        if(child.key == "Users Going"){
                            for users in child.children.allObjects as! [DataSnapshot]{
                                if(users.value as? String == Auth.auth().currentUser!.uid){
                                    Database.database().reference().child("Events").child(snapshot.key).child("Users Going").child(users.key).removeValue()
                                    Database.database().reference().child("Events").child(global.eventsHosted[globalEvent.selectedRow].uuid!).child("Users Going").removeAllObservers()
                                }
                            }
                        }
                    }
                })
            }
            else{
                Database.database().reference().child("Events").child(global.eventsHosted[globalEvent.selectedRow].uuid!).child("Users Going").observe(.childAdded, with: { (snapshot) in
                    if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                        Database.database().reference().child("Events").child(global.eventsHosted[globalEvent.selectedRow].uuid!).child("Users Going").child(snapshot.key).removeValue()
                        Database.database().reference().child("Events").child(global.eventsHosted[globalEvent.selectedRow].uuid!).child("Users Going").removeAllObservers()
                    }
                })
            }
        }
        else if(variables.attended){
            if(global.yourEvents[globalEvent.selectedRow].eventVisibility == "Private"){
                //slidingButton.buttonText = "Request"
                slidingButton.buttonLabel.text = "Request"
                Database.database().reference().child("Events").child(global.yourEvents[globalEvent.selectedRow].uuid!).child("Requested Users").observe(.childAdded, with: { (snapshot) in
                    if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                        Database.database().reference().child("Events").child(global.yourEvents[globalEvent.selectedRow].uuid!).child("Requested Users").child(snapshot.key).removeValue()
                        Database.database().reference().child("Events").child(global.yourEvents[globalEvent.selectedRow].uuid!).child("Requested Users").removeAllObservers()
                    }
                })
                Database.database().reference().child("Events").observe(.childAdded, with: { (snapshot) in
                    for child in snapshot.children.allObjects as! [DataSnapshot]{
                        if(child.key == "Users Going"){
                            for users in child.children.allObjects as! [DataSnapshot]{
                                if(users.value as? String == Auth.auth().currentUser!.uid){
                                    Database.database().reference().child("Events").child(snapshot.key).child("Users Going").child(users.key).removeValue()
                                    Database.database().reference().child("Events").child(global.yourEvents[globalEvent.selectedRow].uuid!).child("Users Going").removeAllObservers()
                                }
                            }
                        }
                    }
                })
            }
            else{
                Database.database().reference().child("Events").child(global.yourEvents[globalEvent.selectedRow].uuid!).child("Users Going").observe(.childAdded, with: { (snapshot) in
                    if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                        Database.database().reference().child("Events").child(global.yourEvents[globalEvent.selectedRow].uuid!).child("Users Going").child(snapshot.key).removeValue()
                        Database.database().reference().child("Events").child(global.yourEvents[globalEvent.selectedRow].uuid!).child("Users Going").removeAllObservers()
                    }
                })
            }
        }
        else{
            if(globalEvent.searching){
                if(globalEvent.filteredEventList[globalEvent.selectedRow].eventVisibility == "Private"){
                    //slidingButton.buttonText = "Request"
                    slidingButton.buttonLabel.text = "Request"
                    Database.database().reference().child("Events").child(globalEvent.filteredEventList[globalEvent.selectedRow].uuid!).child("Requested Users").observe(.childAdded, with: { (snapshot) in
                        if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                            Database.database().reference().child("Events").child(globalEvent.filteredEventList[globalEvent.selectedRow].uuid!).child("Requested Users").child(snapshot.key).removeValue()
                            Database.database().reference().child("Events").child(globalEvent.filteredEventList[globalEvent.selectedRow].uuid!).child("Requested Users").removeAllObservers()
                        }
                    })
                    Database.database().reference().child("Events").observe(.childAdded, with: { (snapshot) in
                        for child in snapshot.children.allObjects as! [DataSnapshot]{
                            if(child.key == "Users Going"){
                                for users in child.children.allObjects as! [DataSnapshot]{
                                    if(users.value as? String == Auth.auth().currentUser!.uid){
                                        Database.database().reference().child("Events").child(snapshot.key).child("Users Going").child(users.key).removeValue()
                                        Database.database().reference().child("Events").child(globalEvent.filteredEventList[globalEvent.selectedRow].uuid!).child("Users Going").removeAllObservers()
                                    }
                                }
                            }
                        }
                    })
                }
                else{
                    let uid = Auth.auth().currentUser?.uid
                    uuid = globalEvent.filteredEventList[globalEvent.selectedRow].uuid!
                    Database.database().reference().child("Events").child(uuid).child("Users Going").observe(.childAdded, with: { (snapshot) in
                        if(snapshot.value as? String == uid){
                            Database.database().reference().child("Events").child(self.uuid).child("Users Going").child(snapshot.key).removeValue()
                            Database.database().reference().child("Events").child(self.uuid).child("Users Going").removeAllObservers()
                        }
                    })
                }
            }
            else{
                if(globalEvent.eventList[globalEvent.selectedRow].eventVisibility == "Private"){
                    //slidingButton.buttonText = "Request"
                    slidingButton.buttonLabel.text = "Request"
                    Database.database().reference().child("Events").child(globalEvent.eventList[globalEvent.selectedRow].uuid!).child("Requested Users").observe(.childAdded, with: { (snapshot) in
                        if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                            Database.database().reference().child("Events").child(globalEvent.eventList[globalEvent.selectedRow].uuid!).child("Requested Users").child(snapshot.key).removeValue()
                            Database.database().reference().child("Events").child(globalEvent.eventList[globalEvent.selectedRow].uuid!).child("Requested Users").removeAllObservers()
                        }
                    })
                    Database.database().reference().child("Events").observe(.childAdded, with: { (snapshot) in
                        for child in snapshot.children.allObjects as! [DataSnapshot]{
                            if(child.key == "Users Going"){
                                for users in child.children.allObjects as! [DataSnapshot]{
                                    if(users.value as? String == Auth.auth().currentUser!.uid){
                                        Database.database().reference().child("Events").child(snapshot.key).child("Users Going").child(users.key).removeValue()
                                        Database.database().reference().child("Events").child(globalEvent.eventList[globalEvent.selectedRow].uuid!).child("Users Going").removeAllObservers()
                                    }
                                }
                            }
                        }
                    })
                }
                else{
                    Database.database().reference().child("Events").child(globalEvent.eventList[globalEvent.selectedRow].uuid!).child("Users Going").observe(.childAdded, with: { (snapshot) in
                        if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                            Database.database().reference().child("Events").child(globalEvent.eventList[globalEvent.selectedRow].uuid!).child("Users Going").child(snapshot.key).removeValue()
                            Database.database().reference().child("Events").child(globalEvent.eventList[globalEvent.selectedRow].uuid!).child("Users Going").removeAllObservers()
                        }
                    })
                }
            }
        }
        }
    }
    @IBOutlet weak var slidingButton: MMSlidingButton!
    @IBAction func mapClicked(_ sender: UIButton) {
        if(variables.link){
            let latitude = variables.event[0].lat
            let longitude = variables.event[0].long
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = variables.event[0].eventName
            mapItem.openInMaps(launchOptions: options)
        }
        else if(variables.check){
            let latitude = global.eventsHosted[globalEvent.selectedRow].lat
            let longitude = global.eventsHosted[globalEvent.selectedRow].long
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = global.eventsHosted[globalEvent.selectedRow].eventName
            mapItem.openInMaps(launchOptions: options)
        }
        else if(variables.attended){
            let latitude = global.yourEvents[globalEvent.selectedRow].lat
            let longitude = global.yourEvents[globalEvent.selectedRow].long
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = global.yourEvents[globalEvent.selectedRow].eventName
            mapItem.openInMaps(launchOptions: options)
        }
        else{
            if(globalEvent.searching){
                let latitude = globalEvent.filteredEventList[globalEvent.selectedRow].lat
                let longitude = globalEvent.filteredEventList[globalEvent.selectedRow].long
                let regionDistance:CLLocationDistance = 10000
                let coordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
                let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                ]
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = globalEvent.filteredEventList[globalEvent.selectedRow].eventName
                mapItem.openInMaps(launchOptions: options)
            }
            else{
                let latitude = globalEvent.eventList[globalEvent.selectedRow].lat
                let longitude = globalEvent.eventList[globalEvent.selectedRow].long
                let regionDistance:CLLocationDistance = 10000
                let coordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
                let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                ]
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = globalEvent.eventList[globalEvent.selectedRow].eventName
                mapItem.openInMaps(launchOptions: options)
            }
        }
    }
    var mapView = MGLMapView()
    var uuid = ""
    @IBOutlet weak var paidIcon: UIImageView!
    @IBAction func pressed(_ sender: UIButton) {
        var host = ""
        if(variables.check){
            host = global.eventsHosted[globalEvent.selectedRow].host!
        }
        else if(variables.attended){
            host = global.yourEvents[globalEvent.selectedRow].host!
        }
        else{
            if(globalEvent.searching){
                host = globalEvent.filteredEventList[globalEvent.selectedRow].host!
            }
            else{
                 host = globalEvent.eventList[globalEvent.selectedRow].host!
            }
        }
        charge.amount = Double(paidAmmount.text!.replacingOccurrences(of: "$", with: ""))!
        Database.database().reference().child("Users").child(host).child("AcctID").observeSingleEvent(of: .value, with: { (snapshot) in
            charge.acct = snapshot.value as! String
        })
        performSegue(withIdentifier: "pay", sender: self)
    }
    @IBOutlet weak var paidAmmount: UILabel!
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var tableView3: UITableView!
    @IBOutlet weak var eventFull: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var interestedImage: UIButton!
    @IBOutlet weak var hostMapView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var eventAddress: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var perPerson: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var numberOfSpots: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var shareLoader: UIActivityIndicatorView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBAction func interestedPressed(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1520)
        if(sender.titleLabel!.text == "I'm Interested!"){
            let uid = Auth.auth().currentUser?.uid
            let ref = Database.database().reference()
            let genNum = NSUUID().uuidString
            if(variables.link){
                uuid = variables.event[0].uuid!
            }
            else if(variables.check){
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
            ref.child("Events").child(uuid).child("Interested Users").updateChildValues([genNum: uid!])
            interestedImage.setTitle("Marked as Interested", for: .normal)
        }
        else{
            let uid = Auth.auth().currentUser?.uid
            var uuid = ""
            if(variables.link){
                uuid = variables.event[0].uuid!
            }
            else if(variables.check){
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
            Database.database().reference().child("Events").child(uuid).child("Interested Users").observe(.childAdded, with: { (snapshot) in
                if(snapshot.value as? String == uid){
                    Database.database().reference().child("Events").child(uuid).child("Interested Users").child(snapshot.key).removeValue()
                    Database.database().reference().child("Events").child(uuid).child("Interested Users").removeAllObservers()
                }
            })
            interestedImage.setTitle("I'm Interested!", for: .normal)
        }
    }
    @IBAction func sharePressed(_ sender: UIButton) {
        sender.setImage(#imageLiteral(resourceName: "ShareClicked"), for: .normal)
        shareLoader.startAnimating()
        AudioServicesPlaySystemSound(1520)
        var uuid = ""
        if(variables.link){
            uuid = variables.event[0].uuid!
        }
        else if(variables.check){
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
        let shareText = "\(eventName.text!)"
        let moreText = "\nLink Not Working? Download Hatch.it from the App Store --> https://u3mt6.app.goo.gl/VunL"
        let url = URL(string: "HatchIt://Event\(uuid)")!
        if let image = self.eventImage.image {
            let vc = UIActivityViewController(activityItems: [image, shareText, url, moreText], applicationActivities: [])
            vc.excludedActivityTypes = [UIActivityType.assignToContact, UIActivityType.postToFacebook, UIActivityType.print, UIActivityType.addToReadingList, UIActivityType.saveToCameraRoll, UIActivityType.openInIBooks, UIActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"), UIActivityType(rawValue: "com.apple.mobilenotes.SharingExtension")]
            shareLoader.stopAnimating()
            self.present(vc, animated: true, completion: nil)
        }
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
        shareButton.setImage(#imageLiteral(resourceName: "ShareIcon-1"), for: .normal)
    }
    override func viewDidLayoutSubviews() {
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 700)
    }
    override func viewWillAppear(_ animated: Bool) {
        shareButton.setImage(#imageLiteral(resourceName: "ShareIcon-1"), for: .normal)
    }
    func unlockSliderDidUnlock(_ slider: MMSlidingButton) {
        resetButton.alpha = 1
        var host = ""
        if(variables.link){
            host = variables.event[0].host!
        }
        else if(variables.check){
            host = global.eventsHosted[globalEvent.selectedRow].host!
        }
        else if(variables.attended){
            host = global.yourEvents[globalEvent.selectedRow].host!
        }
        else{
            if(globalEvent.searching){
                host = globalEvent.filteredEventList[globalEvent.selectedRow].host!
            }
            else{
                host = globalEvent.eventList[globalEvent.selectedRow].host!
            }
        }
        if(variables.pay){
            charge.amount = Double(paidAmmount.text!.replacingOccurrences(of: "$", with: ""))!
            Database.database().reference().child("Users").child(host).child("AcctID").observeSingleEvent(of: .value, with: { (snapshot) in
                charge.acct = snapshot.value as! String
            })
            
        }
        fetchUsers()
    }
    func fetchUsers() {
        AudioServicesPlaySystemSound(1520)
        if(variables.link){
            if(variables.event[0].eventVisibility == "Private"){
                //slidingButton.buttonText = "Request Sent"
                slidingButton.buttonUnlockedText = "Request Sent"
                //slidingButton.buttonLabel.text = "Request Sent"
                let uid = Auth.auth().currentUser?.uid
                let ref = Database.database().reference()
                let uuid = variables.event[0].uuid
                ref.child("Events").child(uuid!).child("Requested Users").childByAutoId().setValue(uid)
            }
            else{
                let uid = Auth.auth().currentUser?.uid
                let genNum = NSUUID().uuidString
                let uuid = variables.event[0].uuid
                let ref = Database.database().reference().child("Events").child(uuid!).child("Users Going")
                ref.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot!) in
                    let numOfUsers = snapshot.childrenCount
                    if(numOfUsers < UInt(variables.event[0].numOfHead!)! || numOfUsers == 0){
                        if(variables.pay){
                            variables.uuid = uuid!
                            self.slidingButton.reset()
                            self.performSegue(withIdentifier: "pay", sender: self)
                            
                        }
                        else{
                            Database.database().reference().child("Events").child(uuid!).child("Users Going").updateChildValues([genNum: uid!])
                        }
                    }
                    else{
                        self.eventFull.alpha = 1
                        self.interestedImage.alpha = 0
                        self.shareButton.alpha = 0
                    }
                })
            }
        }
        else if(variables.check){
            if(global.eventsHosted[globalEvent.selectedRow].eventVisibility == "Private"){
                //slidingButton.buttonText = "Request Sent"
                slidingButton.buttonUnlockedText = "Request Sent"
                //slidingButton.buttonLabel.text = "Request Sent"
                let uid = Auth.auth().currentUser?.uid
                let ref = Database.database().reference()
                let uuid = global.eventsHosted[globalEvent.selectedRow].uuid
                ref.child("Events").child(uuid!).child("Requested Users").childByAutoId().setValue(uid)
            }
            else{
                let uid = Auth.auth().currentUser?.uid
                let genNum = NSUUID().uuidString
                let uuid = global.eventsHosted[globalEvent.selectedRow].uuid
                let ref = Database.database().reference().child("Events").child(uuid!).child("Users Going")
                ref.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot!) in
                    let numOfUsers = snapshot.childrenCount
                    if(numOfUsers < UInt(global.eventsHosted[globalEvent.selectedRow].numOfHead!)! || numOfUsers == 0){
                        if(variables.pay){
                            variables.uuid = uuid!
                            self.slidingButton.reset()
                            self.performSegue(withIdentifier: "pay", sender: self)
                        
                        }
                        else{
                        Database.database().reference().child("Events").child(uuid!).child("Users Going").updateChildValues([genNum: uid!])
                        }
                    }
                    else{
                        self.eventFull.alpha = 1
                        self.interestedImage.alpha = 0
                        self.shareButton.alpha = 0
                    }
                })
            }
        }
        else if(variables.attended){
            if(global.yourEvents[globalEvent.selectedRow].eventVisibility == "Private"){
                //slidingButton.buttonText = "Request Sent"
                slidingButton.buttonUnlockedText = "Request Sent"
                //slidingButton.buttonLabel.text = "Request Sent"
                let uid = Auth.auth().currentUser?.uid
                let ref = Database.database().reference()
                let uuid = global.yourEvents[globalEvent.selectedRow].uuid
                ref.child("Events").child(uuid!).child("Requested Users").childByAutoId().setValue(uid)
            }
            else{
                let uid = Auth.auth().currentUser?.uid
                let genNum = NSUUID().uuidString
                let uuid = global.yourEvents[globalEvent.selectedRow].uuid
                let ref = Database.database().reference().child("Events").child(uuid!).child("Users Going")
                ref.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot!) in
                    let numOfUsers = snapshot.childrenCount
                    if(numOfUsers < UInt(global.yourEvents[globalEvent.selectedRow].numOfHead!)! || numOfUsers == 0){
                        if(variables.pay){
                            variables.uuid = uuid!
                            self.slidingButton.reset()
                            self.performSegue(withIdentifier: "pay", sender: self)
                        }
                        else{
                            Database.database().reference().child("Events").child(uuid!).child("Users Going").updateChildValues([genNum: uid!])
                        }
                    }
                    else{
                        self.eventFull.alpha = 1
                        self.interestedImage.alpha = 0
                        self.shareButton.alpha = 0
                    }
                })
            }
        }
        else{
            if(globalEvent.searching){
                if(globalEvent.filteredEventList[globalEvent.selectedRow].eventVisibility == "Private"){
                    //slidingButton.buttonText = "Request Sent"
                    //slidingButton.buttonLabel.text = "Request Sent"
                    slidingButton.buttonUnlockedText = "Request Sent"
                    let uid = Auth.auth().currentUser?.uid
                    let ref = Database.database().reference()
                    let uuid = globalEvent.filteredEventList[globalEvent.selectedRow].uuid
                    ref.child("Events").child(uuid!).child("Requested Users").childByAutoId().setValue(uid)
                }
                else{
                    let uid = Auth.auth().currentUser?.uid
                    let genNum = NSUUID().uuidString
                    let uuid = globalEvent.filteredEventList[globalEvent.selectedRow].uuid
                    let ref = Database.database().reference().child("Events").child(uuid!).child("Users Going")
                    ref.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot!) in
                        let numOfUsers = snapshot.childrenCount
                        if(numOfUsers < globalEvent.filteredEventList[globalEvent.selectedRow].usersGoing.count || numOfUsers == 0){
                            if(variables.pay){
                                variables.uuid = uuid!
                                self.slidingButton.reset()
                                self.performSegue(withIdentifier: "pay", sender: self)
                            }
                            else{
                                Database.database().reference().child("Events").child(uuid!).child("Users Going").updateChildValues([genNum: uid!])
                            }
                        }
                        else{
                            self.eventFull.alpha = 1
                            self.interestedImage.alpha = 0
                            self.shareButton.alpha = 0
                        }
                    })
                }
            }
            else{
                if(globalEvent.eventList[globalEvent.selectedRow].eventVisibility == "Private"){
                    //slidingButton.buttonText = "Request Sent"
                    //slidingButton.buttonLabel.text = "Request Sent"
                    slidingButton.buttonUnlockedText = "Request Sent"
                    let uid = Auth.auth().currentUser?.uid
                    let ref = Database.database().reference()
                    let uuid = globalEvent.eventList[globalEvent.selectedRow].uuid
                    ref.child("Events").child(uuid!).child("Requested Users").childByAutoId().setValue(uid)
                }
                else{
                    let uid = Auth.auth().currentUser?.uid
                    let genNum = NSUUID().uuidString
                    let uuid = globalEvent.eventList[globalEvent.selectedRow].uuid
                    let ref = Database.database().reference().child("Events").child(uuid!).child("Users Going")
                    ref.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot!) in
                        let numOfUsers = snapshot.childrenCount
                        if(numOfUsers < Int(globalEvent.eventList[globalEvent.selectedRow].numOfHead!)!){
                            if(variables.pay){
                                variables.uuid = uuid!
                                self.slidingButton.reset()
                                self.performSegue(withIdentifier: "pay", sender: self)
                            }
                            else{
                                Database.database().reference().child("Events").child(uuid!).child("Users Going").updateChildValues([genNum: uid!])
                            }
                        }
                        else{
                            self.eventFull.alpha = 1
                            self.interestedImage.alpha = 0
                            self.shareButton.alpha = 0
                        }
                    })
                }
            }
        }
    }
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

    override func viewDidLoad() {
        super.viewDidLoad()
        variables.pay = false
        paidIcon.isHidden = true
        paidAmmount.isHidden = true
        perPerson.isHidden = true
        slidingButton.buttonFont = UIFont(name: "Lato-Light", size: 20)!
        slidingButton.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(fetchUsers), name: NSNotification.Name(rawValue: "callForAlert10"), object: nil)
        eventFull.layer.cornerRadius = 10
        shareButton.layer.borderColor = UIColor.init(red: 176/255, green: 106/255, blue: 179/255, alpha: 1).cgColor
        shareButton.layer.borderWidth = 1
        shareButton.layer.cornerRadius = shareButton.frame.height / 2
        gradientSet.append([gradientOne, gradientTwo])
        gradientSet.append([gradientTwo, gradientOne])
        gradient.frame = slidingButton.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.startPoint = CGPoint(x:0.5, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        gradient.drawsAsynchronously = true
        slidingButton.layer.addSublayer(gradient)
        animateGradient()
        mapView.allowsScrolling = false
        mapView.allowsZooming = false
        mapView.allowsRotating = false
        mapView.allowsTilting = false
        tableView3.tableFooterView = UIView()
        let urlString = URL(string: "mapbox://styles/stephenth0ma5/cjayeqlub44lh2qqyzmmpynhc")
        mapView = MGLMapView(frame: hostMapView.bounds, styleURL: urlString)
        mapView.delegate = self
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.showsUserLocation = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostMapView.addSubview(mapView)
        tableView3.delegate = self
        tableView3.dataSource = self
        tableView3.reloadData()
        self.resetButton.alpha = 0
        shareLoader.center = scrollView.center
        loader.startAnimating()
        editEvent.clipsToBounds = true
        editEvent.layer.cornerRadius = editEvent.frame.height / 2
        if(values.link){
            print("ENTERED")
            values.link = false
            variables.link = true
            print(values.uuid)
            Database.database().reference().child("Events").child(values.uuid).observe(.childAdded, with: { (snapshot) in
                print(snapshot.key)
                if(snapshot.key == "Host"){
                    if(snapshot.value as! String == Auth.auth().currentUser!.uid){
                        self.editEvent.alpha = 1
                        self.overlay.alpha = 1
                    }
                    if(snapshot.key == "Price Type"){
                        print("YES")
                        if(snapshot.value as! String == "Paid"){
                            self.paidIcon.isHidden = false
                            self.paidAmmount.isHidden = false
                            self.perPerson.isHidden = false
                            variables.pay = true
                            print("HELLO")
                        }
                    }
                    if(snapshot.key == "Price"){
                        self.paidAmmount.text = "\(snapshot.value as! String)"
                    }
                }
            })
            
            Database.database().reference().child("Events").child(values.uuid).observe(.childAdded, with: { (snapshot) in
                Database.database().reference().child("Events").child(values.uuid).child("Interested Users").observe(.childAdded, with: { (snapshot) in
                    if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                        self.interestedImage.setTitle("Marked as Interested", for: .normal)
                    }
                    else{
                        self.interestedImage.setTitle("I'm Interested!", for: .normal)
                    }
                })
                
            })
            if(Int(variables.event[0].numOfHead!)! <= 100){
                if(Int(variables.event[0].numOfHead!)! == 0){
                    if(variables.event[0].usersGoing.contains(Auth.auth().currentUser!.uid)){
                        self.eventFull.alpha = 1
                        self.interestedImage.alpha = 0
                        self.shareButton.alpha = 0
                    }
                }
            }
            if(variables.event[0].eventVisibility == "Private"){
                Database.database().reference().child("Events").child(values.uuid).child("Users Going").observe(.childAdded, with: { (snapshot) in
                    if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                        self.slidingButton.buttonUnlockedText = "Going"
                        self.slidingButton.unlock()
                        self.resetButton.alpha = 1
                        variables.approved = true
                    }
                })
                if(variables.approved == false){
                    self.tableView3.alpha = 0
                    self.slidingButton.buttonText = "Request"
                    //self.slidingButton.buttonLabel.text = "Request"
                    Database.database().reference().child("Events").child(values.uuid).observe(.childAdded, with: { (snapshot) in
                        if(snapshot.key == "Requested Users"){
                            for child in snapshot.children.allObjects as! [DataSnapshot]{
                                if(child.value as? String == Auth.auth().currentUser?.uid){
                                    AudioServicesPlaySystemSound(1520)
                                    self.slidingButton.buttonUnlockedText = "Request Sent"
                                    self.slidingButton.unlock()
                                    self.resetButton.alpha = 1
                                }
                            }
                        }
                    })
                    self.shareButton.alpha = 0
                    self.interestedImage.alpha = 0
                }
            }
            else{
                self.slidingButton.buttonText = "Go"
                //self.slidingButton.buttonLabel.text = "Go"
                Database.database().reference().child("Events").child(values.uuid).observe(.childAdded, with: { (snapshot) in
                    if(snapshot.key == "Users Going"){
                        for child in snapshot.children.allObjects as! [DataSnapshot]{
                            if(child.value as? String == Auth.auth().currentUser?.uid){
                                AudioServicesPlaySystemSound(1520)
                                self.slidingButton.buttonUnlockedText = "Going"
                                self.slidingButton.unlock()
                                self.resetButton.alpha = 1
                            }
                        }
                    }
                })
            }
            let startTime = variables.event[0].startTime
            let endTime = variables.event[0].endTime
            self.eventTime.text = "\(startTime!) - \(endTime!)"
            self.eventAddress.text = variables.event[0].eventAddress
            self.eventDate.text = variables.event[0].eventDate
            self.eventName.text =  variables.event[0].eventName
            self.eventLocation.text = variables.event[0].location
            self.eventDescription.text = variables.event[0].eventDescription
            if(Int(variables.event[0].numOfHead!)! > 100){
                self.numberOfSpots.text = "Unlimited"
            }
            else{
                self.numberOfSpots.text = "\(variables.event[0].numOfHead!)"
            }
            let lat = variables.event[0].lat
            let long = variables.event[0].long
            let annotation = MGLPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
            annotation.title = self.eventName.text
            self.mapView.addAnnotation(annotation)
            self.mapView.setCenter(CLLocationCoordinate2D(latitude: lat!, longitude: long!), zoomLevel: 9, animated: false)
            let url = URL(string: variables.event[0].eventImage!)
            let session = URLSession(configuration: .default)
            let downloadPicTask = session.dataTask(with: url!) { (data, response, error) in
                if let e = error {
                    print(e)
                } else {
                    if let res = response as? HTTPURLResponse {
                        print(res.statusCode)
                        if let imageData = data {
                            DispatchQueue.main.async {
                                self.eventImage.image = UIImage(data: imageData)
                                self.loader.stopAnimating()
                            }
                        }
                    }
                }
            }
            downloadPicTask.resume()
        }
        else if(variables.check){
            Database.database().reference().child("Events").child(global.eventsHosted[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                if(snapshot.key == "Host"){
                    if(snapshot.value as! String == Auth.auth().currentUser!.uid){
                        self.editEvent.alpha = 1
                        self.overlay.alpha = 1
                    }
                }
                if(snapshot.key == "Price Type"){
                    if(snapshot.value as! String == "Paid"){
                        self.paidIcon.isHidden = false
                        self.paidAmmount.isHidden = false
                        self.perPerson.isHidden = false
                        variables.pay = true
                    }
                }
                if(snapshot.key == "Price"){
                    self.paidAmmount.text = "\(snapshot.value as! String)"
                }
            })
           
            Database.database().reference().child("Events").child(global.eventsHosted[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                Database.database().reference().child("Events").child(global.eventsHosted[globalEvent.selectedRow].uuid!).child("Interested Users").observe(.childAdded, with: { (snapshot) in
                    if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                        self.interestedImage.setTitle("Marked as Interested", for: .normal)
                    }
                    else{
                        self.interestedImage.setTitle("I'm Interested!", for: .normal)
                    }
                })
                
            })
            if(Int(global.eventsHosted[globalEvent.selectedRow].numOfHead!)! <= 100){
                if(Int(global.eventsHosted[globalEvent.selectedRow].numOfHead!)! == 0){
                    if(!global.eventsHosted[globalEvent.selectedRow].usersGoing.contains(Auth.auth().currentUser!.uid)){
                        eventFull.alpha = 1
                        interestedImage.alpha = 0
                        shareButton.alpha = 0
                    }
                }
            }
            if(global.eventsHosted[globalEvent.selectedRow].eventVisibility == "Private"){
               print(global.eventsHosted[globalEvent.selectedRow].uuid!)
                Database.database().reference().child("Events").child(global.eventsHosted[globalEvent.selectedRow].uuid!).child("Users Going").observe(.childAdded, with: { (snapshot) in
                    if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                        self.slidingButton.buttonUnlockedText = "Going"
                        self.slidingButton.unlock()
                        self.resetButton.alpha = 1
                        variables.approved = true
                    }
                })
                if(variables.approved == false){
                    tableView3.alpha = 0
                    self.slidingButton.buttonText = "Request"
                    //self.slidingButton.buttonLabel.text = "Request"
                    Database.database().reference().child("Events").child(global.eventsHosted[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                        if(snapshot.key == "Requested Users"){
                            for child in snapshot.children.allObjects as! [DataSnapshot]{
                                if(child.value as? String == Auth.auth().currentUser?.uid){
                                    AudioServicesPlaySystemSound(1520)
                                    self.slidingButton.buttonUnlockedText = "Request Sent"
                                    self.slidingButton.unlock()
                                    self.resetButton.alpha = 1
                                }
                            }
                        }
                    })
                    shareButton.alpha = 0
                    interestedImage.alpha = 0
                }
            }
            else{
                self.slidingButton.buttonText = "Go"
                //self.slidingButton.buttonLabel.text = "Go"
                Database.database().reference().child("Events").child(global.eventsHosted[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                    if(snapshot.key == "Users Going"){
                        for child in snapshot.children.allObjects as! [DataSnapshot]{
                            if(child.value as? String == Auth.auth().currentUser?.uid){
                                AudioServicesPlaySystemSound(1520)
                                self.slidingButton.buttonUnlockedText = "Going"
                                self.slidingButton.unlock()
                                self.resetButton.alpha = 1
                            }
                        }
                    }
                })
            }
            let startTime = global.eventsHosted[globalEvent.selectedRow].startTime
            let endTime = global.eventsHosted[globalEvent.selectedRow].endTime
            eventTime.text = "\(startTime!) - \(endTime!)"
            eventAddress.text = global.eventsHosted[globalEvent.selectedRow].eventAddress
            eventDate.text = global.eventsHosted[globalEvent.selectedRow].eventDate
            eventName.text =  global.eventsHosted[globalEvent.selectedRow].eventName
            eventLocation.text = global.eventsHosted[globalEvent.selectedRow].location
            eventDescription.text = global.eventsHosted[globalEvent.selectedRow].eventDescription
            if(Int(global.eventsHosted[globalEvent.selectedRow].numOfHead!)! > 100){
                numberOfSpots.text = "Unlimited"
            }
            else{
                numberOfSpots.text = "\(Int(global.eventsHosted[globalEvent.selectedRow].numOfHead!)!)"
            }
            let lat = global.eventsHosted[globalEvent.selectedRow].lat
            let long = global.eventsHosted[globalEvent.selectedRow].long
            let annotation = MGLPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
            annotation.title = eventName.text
            mapView.addAnnotation(annotation)
            mapView.setCenter(CLLocationCoordinate2D(latitude: lat!, longitude: long!), zoomLevel: 9, animated: false)
            let url = URL(string: global.eventsHosted[globalEvent.selectedRow].eventImage!)
            let session = URLSession(configuration: .default)
            let downloadPicTask = session.dataTask(with: url!) { (data, response, error) in
                if let e = error {
                    print(e)
                } else {
                    if let res = response as? HTTPURLResponse {
                        print(res.statusCode)
                        if let imageData = data {
                            DispatchQueue.main.async {
                                self.eventImage.image = UIImage(data: imageData)
                                self.loader.stopAnimating()
                            }
                        }
                    }
                }
            }
            downloadPicTask.resume()
        }
        else if(variables.attended){
            Database.database().reference().child("Events").child(global.yourEvents[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                if(snapshot.key == "Host"){
                    if(snapshot.value as! String == Auth.auth().currentUser!.uid){
                        self.editEvent.alpha = 1
                        self.overlay.alpha = 1
                    }
                }
                if(snapshot.key == "Price Type"){
                    if(snapshot.value as! String == "Paid"){
                        self.paidIcon.isHidden = false
                        self.paidAmmount.isHidden = false
                        self.perPerson.isHidden = false
                        variables.pay = true
                    }
                }
                if(snapshot.key == "Price"){
                    self.paidAmmount.text = "\(snapshot.value as! String)"
                }
            })
            Database.database().reference().child("Events").child(global.yourEvents[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                Database.database().reference().child("Events").child(global.yourEvents[globalEvent.selectedRow].uuid!).child("Interested Users").observe(.childAdded, with: { (snapshot) in
                    if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                        self.interestedImage.setTitle("Marked as Interested", for: .normal)
                    }
                    else{
                        self.interestedImage.setTitle("I'm Interested!", for: .normal)
                    }
                })
                
            })
            if(Int(global.yourEvents[globalEvent.selectedRow].numOfHead!)! <= 100){
                if(Int(global.yourEvents[globalEvent.selectedRow].numOfHead!)! == 0){
                    if(!global.yourEvents[globalEvent.selectedRow].usersGoing.contains(Auth.auth().currentUser!.uid)){
                        eventFull.alpha = 1
                        interestedImage.alpha = 0
                        shareButton.alpha = 0
                    }
                }
            }
            if(global.yourEvents[globalEvent.selectedRow].eventVisibility == "Private"){
                Database.database().reference().child("Events").child(global.yourEvents[globalEvent.selectedRow].uuid!).child("Users Going").observe(.childAdded, with: { (snapshot) in
                    if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                        self.slidingButton.buttonUnlockedText = "Going"
                        self.slidingButton.unlock()
                        self.resetButton.alpha = 1
                        variables.approved = true
                    }
                })
                if(variables.approved == false){
                    tableView3.alpha = 0
                    self.slidingButton.buttonText = "Request"
                    //self.slidingButton.buttonLabel.text = "Request"
                    Database.database().reference().child("Events").child(global.yourEvents[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                        if(snapshot.key == "Requested Users"){
                            for child in snapshot.children.allObjects as! [DataSnapshot]{
                                if(child.value as? String == Auth.auth().currentUser?.uid){
                                    AudioServicesPlaySystemSound(1520)
                                    self.slidingButton.buttonUnlockedText = "Request Sent"
                                    self.slidingButton.unlock()
                                    self.resetButton.alpha = 1
                                }
                            }
                        }
                    })
                    shareButton.alpha = 0
                    interestedImage.alpha = 0
                }
            }
            else{
                self.slidingButton.buttonText = "Go"
                //self.slidingButton.buttonLabel.text = "Go"
                Database.database().reference().child("Events").child(global.yourEvents[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                    if(snapshot.key == "Users Going"){
                        for child in snapshot.children.allObjects as! [DataSnapshot]{
                            if(child.value as? String == Auth.auth().currentUser?.uid){
                                AudioServicesPlaySystemSound(1520)
                                self.slidingButton.buttonUnlockedText = "Going"
                                self.slidingButton.unlock()
                                self.resetButton.alpha = 1
                            }
                        }
                    }
                })
            }
            let startTime = global.yourEvents[globalEvent.selectedRow].startTime
            let endTime = global.yourEvents[globalEvent.selectedRow].endTime
            eventTime.text = "\(startTime!) - \(endTime!)"
            eventAddress.text = global.yourEvents[globalEvent.selectedRow].eventAddress
            eventDate.text = global.yourEvents[globalEvent.selectedRow].eventDate
            eventName.text =  global.yourEvents[globalEvent.selectedRow].eventName
            eventLocation.text = global.yourEvents[globalEvent.selectedRow].location
            eventDescription.text = global.yourEvents[globalEvent.selectedRow].eventDescription
            if(Int(global.yourEvents[globalEvent.selectedRow].numOfHead!)! > 100){
                numberOfSpots.text = "Unlimited"
            }
            else{
                numberOfSpots.text = "\(Int(global.yourEvents[globalEvent.selectedRow].numOfHead!)!)"
            }
            let lat = global.yourEvents[globalEvent.selectedRow].lat
            let long = global.yourEvents[globalEvent.selectedRow].long
            let annotation = MGLPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
            annotation.title = eventName.text
            mapView.addAnnotation(annotation)
            mapView.setCenter(CLLocationCoordinate2D(latitude: lat!, longitude: long!), zoomLevel: 9, animated: false)
            let url = URL(string: global.yourEvents[globalEvent.selectedRow].eventImage!)
            let session = URLSession(configuration: .default)
            let downloadPicTask = session.dataTask(with: url!) { (data, response, error) in
                if let e = error {
                    print(e)
                } else {
                    if let res = response as? HTTPURLResponse {
                        print(res.statusCode)
                        if let imageData = data {
                            DispatchQueue.main.async {
                                self.eventImage.image = UIImage(data: imageData)
                                self.loader.stopAnimating()
                            }
                        }
                    }
                }
            }
            downloadPicTask.resume()
        }
        else{
            if(globalEvent.searching){
                Database.database().reference().child("Events").child(globalEvent.filteredEventList[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                    if(snapshot.key == "Host"){
                        if(snapshot.value as! String == Auth.auth().currentUser!.uid){
                            self.editEvent.alpha = 1
                            self.overlay.alpha = 1
                        }
                    }
                    if(snapshot.key == "Price Type"){
                        if(snapshot.value as! String == "Paid"){
                            self.paidIcon.isHidden = false
                            self.paidAmmount.isHidden = false
                            self.perPerson.isHidden = false
                            variables.pay = true
                        }
                    }
                    if(snapshot.key == "Price"){
                        self.paidAmmount.text = "\(snapshot.value as! String)"
                    }
                })
                Database.database().reference().child("Events").child(globalEvent.filteredEventList[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                    Database.database().reference().child("Events").child(globalEvent.filteredEventList[globalEvent.selectedRow].uuid!).child("Interested Users").observe(.childAdded, with: { (snapshot) in
                        if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                            self.interestedImage.setTitle("Marked as Interested", for: .normal)
                        }
                        else{
                            self.interestedImage.setTitle("I'm Interested!", for: .normal)
                        }
                    })
                    
                })
                if(Int(globalEvent.filteredEventList[globalEvent.selectedRow].numOfHead!)! <= 100){
                    if(Int(globalEvent.filteredEventList[globalEvent.selectedRow].numOfHead!) == 0){
                        if(!globalEvent.filteredEventList[globalEvent.selectedRow].usersGoing.contains(Auth.auth().currentUser!.uid)){
                            eventFull.alpha = 1
                            interestedImage.alpha = 0
                            shareButton.alpha = 0
                        }
                    }
                    
                }
                if(globalEvent.filteredEventList[globalEvent.selectedRow].eventVisibility == "Private"){
                    Database.database().reference().child("Events").child(globalEvent.filteredEventList[globalEvent.selectedRow].uuid!).child("Users Going").observe(.childAdded, with: { (snapshot) in
                        if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                            self.slidingButton.buttonUnlockedText = "Going"
                            self.slidingButton.unlock()
                            self.resetButton.alpha = 1
                            variables.approved = true
                        }
                    })
                    if(variables.approved == false){
                        tableView3.alpha = 0
                        self.resetButton.alpha = 0
                        slidingButton.buttonText = "Request"
                        //slidingButton.buttonLabel.text = "Request"
                        Database.database().reference().child("Events").child(globalEvent.filteredEventList[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                            if(snapshot.key == "Requested Users"){
                                for child in snapshot.children.allObjects as! [DataSnapshot]{
                                    
                                    if(child.value as? String == Auth.auth().currentUser?.uid){
                                        self.slidingButton.unlock()
                                        AudioServicesPlaySystemSound(1520)
                                        self.resetButton.alpha = 1
                                        self.slidingButton.buttonUnlockedText = "Request Sent"
                                    }
                                }
                            }
                        })
                        shareButton.alpha = 0
                        interestedImage.alpha = 0
                    }
                }
                else{
                    self.slidingButton.buttonText = "Go"
                    //self.slidingButton.buttonLabel.text = "Go"
                    Database.database().reference().child("Events").child(globalEvent.filteredEventList[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                        if(snapshot.key == "Users Going"){
                            for child in snapshot.children.allObjects as! [DataSnapshot]{
                                if(child.value as? String == Auth.auth().currentUser?.uid){
                                    AudioServicesPlaySystemSound(1520)
                                    self.slidingButton.buttonUnlockedText = "Going"
                                    self.slidingButton.unlock()
                                    self.resetButton.alpha = 1
                                }
                            }
                        }
                    })
                }
                let startTime = globalEvent.filteredEventList[globalEvent.selectedRow].startTime
                let endTime = globalEvent.filteredEventList[globalEvent.selectedRow].endTime
                eventTime.text = "\(startTime!) - \(endTime!)"
                eventAddress.text = globalEvent.filteredEventList[globalEvent.selectedRow].eventAddress
                eventDate.text = globalEvent.filteredEventList[globalEvent.selectedRow].eventDate
                eventName.text =  globalEvent.filteredEventList[globalEvent.selectedRow].eventName
                eventLocation.text = globalEvent.filteredEventList[globalEvent.selectedRow].location
                eventDescription.text = globalEvent.filteredEventList[globalEvent.selectedRow].eventDescription
                if(Int(globalEvent.filteredEventList[globalEvent.selectedRow].numOfHead!)! > 100){
                    numberOfSpots.text = "Unlimited"
                }
                else{
                    numberOfSpots.text = "\(Int(globalEvent.filteredEventList[globalEvent.selectedRow].numOfHead!)!)"
                }
                let lat = globalEvent.filteredEventList[globalEvent.selectedRow].lat
                let long = globalEvent.filteredEventList[globalEvent.selectedRow].long
                let annotation = MGLPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                annotation.title = eventName.text
                mapView.addAnnotation(annotation)
                mapView.setCenter(CLLocationCoordinate2D(latitude: lat!, longitude: long!), zoomLevel: 9, animated: false)
                let url = URL(string: globalEvent.filteredEventList[globalEvent.selectedRow].eventImage!)
                let session = URLSession(configuration: .default)
                let downloadPicTask = session.dataTask(with: url!) { (data, response, error) in
                    if let e = error {
                        print(e)
                    } else {
                        if let res = response as? HTTPURLResponse {
                            print(res.statusCode)
                            if let imageData = data {
                                DispatchQueue.main.async {
                                    self.eventImage.image = UIImage(data: imageData)
                                    self.loader.stopAnimating()
                                }
                            }
                        }
                    }
                }
                
                downloadPicTask.resume()
            }
            else{
                Database.database().reference().child("Events").child(globalEvent.eventList[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                    if(snapshot.key == "Host"){
                        if(snapshot.value as! String == Auth.auth().currentUser!.uid){
                            self.editEvent.alpha = 1
                            self.overlay.alpha = 1
                        }
                    }
                    if(snapshot.key == "Price Type"){
                        if(snapshot.value as! String == "Paid"){
                            self.paidIcon.isHidden = false
                            self.paidAmmount.isHidden = false
                            self.perPerson.isHidden = false
                            variables.pay = true
                        }
                    }
                    if(snapshot.key == "Price"){
                        self.paidAmmount.text = "\(snapshot.value as! String)"
                    }
                    
                })
                Database.database().reference().child("Events").child(globalEvent.eventList[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                    Database.database().reference().child("Events").child(globalEvent.eventList[globalEvent.selectedRow].uuid!).child("Interested Users").observe(.childAdded, with: { (snapshot) in
                        if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                            self.interestedImage.setTitle("Marked as Interested", for: .normal)
                        }
                        else{
                            self.interestedImage.setTitle("I'm Interested!", for: .normal)
                        }
                    })
                    
                })
                if(Int(globalEvent.eventList[globalEvent.selectedRow].numOfHead!)! <= 100){
                    if(Int(globalEvent.eventList[globalEvent.selectedRow].numOfHead!)! == 0){
                        if(!globalEvent.eventList[globalEvent.selectedRow].usersGoing.contains(Auth.auth().currentUser!.uid)){
                            eventFull.alpha = 1
                            interestedImage.alpha = 0
                            shareButton.alpha = 0
                        }
                    }
                    
                }
                if(globalEvent.eventList[globalEvent.selectedRow].eventVisibility == "Private"){
                    Database.database().reference().child("Events").child(globalEvent.eventList[globalEvent.selectedRow].uuid!).child("Users Going").observe(.childAdded, with: { (snapshot) in
                        if(snapshot.value as? String == Auth.auth().currentUser?.uid){
                            self.slidingButton.buttonUnlockedText = "Going"
                            self.slidingButton.unlock()
                            self.resetButton.alpha = 1
                            variables.approved = true
                        }
                    })
                    if(variables.approved == false){
                        tableView3.alpha = 0
                        self.resetButton.alpha = 0
                        slidingButton.buttonText = "Request"
                        //slidingButton.buttonLabel.text = "Request"
                        Database.database().reference().child("Events").child(globalEvent.eventList[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                            if(snapshot.key == "Requested Users"){
                                for child in snapshot.children.allObjects as! [DataSnapshot]{
                                    
                                    if(child.value as? String == Auth.auth().currentUser?.uid){
                                        AudioServicesPlaySystemSound(1520)
                                        self.slidingButton.buttonUnlockedText = "Request Sent"
                                        self.slidingButton.unlock()
                                        self.resetButton.alpha = 1
                                    }
                                }
                            }
                        })
                        shareButton.alpha = 0
                        interestedImage.alpha = 0
                    }
                }
                else{
                    self.slidingButton.buttonText = "Go"
                    //self.slidingButton.buttonLabel.text = "Go"
                    Database.database().reference().child("Events").child(globalEvent.eventList[globalEvent.selectedRow].uuid!).observe(.childAdded, with: { (snapshot) in
                        if(snapshot.key == "Users Going"){
                            for child in snapshot.children.allObjects as! [DataSnapshot]{
                                if(child.value as? String == Auth.auth().currentUser?.uid){
                                    AudioServicesPlaySystemSound(1520)
                                    self.slidingButton.buttonUnlockedText = "Going"
                                    self.slidingButton.unlock()
                                    self.resetButton.alpha = 1
                                }
                            }
                        }
                    })
                }
                let startTime = globalEvent.eventList[globalEvent.selectedRow].startTime
                let endTime = globalEvent.eventList[globalEvent.selectedRow].endTime
                eventTime.text = "\(startTime!) - \(endTime!)"
                eventAddress.text = globalEvent.eventList[globalEvent.selectedRow].eventAddress
                eventDate.text = globalEvent.eventList[globalEvent.selectedRow].eventDate
                eventName.text =  globalEvent.eventList[globalEvent.selectedRow].eventName
                eventLocation.text = globalEvent.eventList[globalEvent.selectedRow].location
                eventDescription.text = globalEvent.eventList[globalEvent.selectedRow].eventDescription
                if(Int(globalEvent.eventList[globalEvent.selectedRow].numOfHead!)! > 100){
                    numberOfSpots.text = "Unlimited"
                }
                else{
                    numberOfSpots.text = "\(Int(globalEvent.eventList[globalEvent.selectedRow].numOfHead!)!)"
                }
                let lat = globalEvent.eventList[globalEvent.selectedRow].lat
                let long = globalEvent.eventList[globalEvent.selectedRow].long
                let annotation = MGLPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                annotation.title = eventName.text
                mapView.addAnnotation(annotation)
                mapView.setCenter(CLLocationCoordinate2D(latitude: lat!, longitude: long!), zoomLevel: 9, animated: false)
                let url = URL(string: globalEvent.eventList[globalEvent.selectedRow].eventImage!)
                let session = URLSession(configuration: .default)
                let downloadPicTask = session.dataTask(with: url!) { (data, response, error) in
                    if let e = error {
                        print(e)
                    } else {
                        if let res = response as? HTTPURLResponse {
                            print(res.statusCode)
                            if let imageData = data {
                                DispatchQueue.main.async {
                                    self.eventImage.image = UIImage(data: imageData)
                                    self.loader.stopAnimating()
                                }
                            }
                        }
                    }
                }
                
                downloadPicTask.resume()
            }
        }
    }
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "usersGoing", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == self.tableView3)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell3", for: indexPath)
            cell.textLabel?.text = "Guest Information"
            cell.textLabel?.font = UIFont(name: "Lato-Thin", size: 17)
            return cell
        }
        return UITableViewCell()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
