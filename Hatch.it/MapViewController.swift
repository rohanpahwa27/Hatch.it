//
//  FirstViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 9/13/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase
import Firebase
import Mapbox
import FBSDKCoreKit
import AudioToolbox
struct globalAnnotation{
    static var annotation = [Annotation]()
    static var num = 0
}
class MapViewController: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate, UISearchBarDelegate {
    var eventUUID = ""
    var searchTextArr = [String]()
    //IBOutlets
    @IBOutlet weak var circleOne: UIImageView!
    @IBOutlet weak var circleTwo: UIImageView!
    @IBOutlet weak var circleThree: UIImageView!
    @IBOutlet weak var circleFour: UIImageView!
    @IBOutlet weak var circleFive: UIImageView!
    @IBOutlet weak var circleSix: UIImageView!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDistance: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventFull: UILabel!
    @IBOutlet weak var currentLocationB: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBAction func joinClicked(_ sender: UIButton) {
        Database.database().reference().child("Events").child(eventUUID).observe(.childAdded, with: { (snapshot) in
            var numOfHeads = ""
            var usersGoing = ""
            if(snapshot.key == "Users Going"){
                print("\(snapshot.childrenCount)")
                usersGoing = "\(snapshot.childrenCount)"
            }
            if(snapshot.key == "Number of Heads"){
                if(snapshot.value as? String == "Unlimited"){
                    
                }
                else{
                     numOfHeads = snapshot.value as! String
                }
            }
            if(usersGoing == numOfHeads){
                self.joinButton.alpha = 0
                self.eventFull.alpha = 1
                
            }
            else{
                Database.database().reference().child("Events").child(self.eventUUID).child("Users Going").childByAutoId().setValue(Auth.auth().currentUser?.uid)
                self.performSegue(withIdentifier: "add", sender: self)
            }
        })
    }
    @IBAction func currentLocation(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1520)
        let locManager = CLLocationManager()
        let lat = locManager.location?.coordinate.latitude
        let long = locManager.location?.coordinate.longitude
        mapView.setCenter(CLLocationCoordinate2D(latitude: lat!, longitude: long!), zoomLevel: 9, animated: true)
        dismissViews()
    }
    @IBOutlet weak var popupView: UIView!
    //Variables and Constants
    var mapView = MGLMapView()
    var eventID: String?
    var relevantEvents:[(eventID: String, relevance: Int)] = []
    var ref: DatabaseReference!
    var enter = false
    //Override Functions
    override func viewWillAppear(_ animated: Bool) {
        let allAnnotations = self.mapView.annotations
        if(allAnnotations != nil){
            mapView.removeAnnotations(allAnnotations!)
        }
        var okay = false
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                okay = false
            case .authorizedAlways, .authorizedWhenInUse:
                okay = true
            }
        } else {
            okay = false
        }
        if(okay){
        getEvents()
        fetchEvents()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        circleOne.layer.cornerRadius = circleOne.frame.height/2
        circleTwo.layer.cornerRadius = circleTwo.frame.height/2
        circleThree.layer.cornerRadius = circleThree.frame.height/2
        circleFour.layer.cornerRadius = circleFour.frame.height/2
        circleFive.layer.cornerRadius = circleFive.frame.height/2
        circleSix.layer.cornerRadius = circleSix.frame.height/2
        globalAnnotation.annotation = []
        popupView.alpha = 0
        popupView.layer.cornerRadius = 10
        popupView.clipsToBounds = true
        currentLocationB.layer.borderWidth = 1
        currentLocationB.layer.borderColor = UIColor.black.cgColor
        currentLocationB.layer.cornerRadius = 10
        let url = URL(string: "mapbox://styles/stephenth0ma5/cjayeqlub44lh2qqyzmmpynhc")
        mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.delegate = self
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.showsUserLocation = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        var okay = false
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                okay = false
            case .authorizedAlways, .authorizedWhenInUse:
                okay = true
            }
        } else {
            okay = false
        }
        if(okay){
            let locManager = CLLocationManager()
            let lat = locManager.location?.coordinate.latitude
            let long = locManager.location?.coordinate.longitude
            mapView.setCenter(CLLocationCoordinate2D(latitude: lat!, longitude: long!), zoomLevel: 9, animated: false)
        }
        let placeholderAttribute: [String : AnyObject] = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Lato-Light", size: 16)!]
        let attributedPlaceholder: NSAttributedString = NSAttributedString(string: "What Do You Want To Do Today?", attributes: placeholderAttribute)
        let textFieldPlaceHolder = searchBar.value(forKey: "searchField") as? UITextField
        textFieldPlaceHolder?.attributedPlaceholder = attributedPlaceholder
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.font = UIFont(name: "Lato-Regular", size: 16)
            textfield.textColor = UIColor.white
            if let backgroundview = textfield.subviews.first {
                let gradient = CAGradientLayer()
                gradient.frame = searchBar.bounds
                gradient.colors = [
                    UIColor(red: 198/255, green: 152/255, blue: 201/255, alpha: 1).cgColor, UIColor(red: 129/255, green: 151/255, blue: 229/255, alpha: 1).cgColor
                ]
                gradient.startPoint = CGPoint(x:0, y:0)
                gradient.endPoint = CGPoint(x:1, y:1)
                backgroundview.layer.addSublayer(gradient)
                backgroundview.backgroundColor = UIColor(red: 101/255, green: 98/255, blue: 190/255, alpha: 1)
                backgroundview.layer.cornerRadius = 14;
                backgroundview.clipsToBounds = true;
            }
        }
        view.addSubview(mapView)
        view.addSubview(searchBar)
        view.addSubview(currentLocationB)
        view.bringSubview(toFront: popupView)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissViews))
        view.addGestureRecognizer(tap)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //Functions/
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if(searchBar.text == nil || searchBar.text == ""){
            let allAnnotations = self.mapView.annotations
            mapView.removeAnnotations(allAnnotations!)
            getEvents()
        }
    }
    func fetchEvents() {
        var currentLocation: CLLocation!
        let locManager = CLLocationManager()
        currentLocation = locManager.location
        let currentlong = currentLocation.coordinate.longitude
        let currentlat = currentLocation.coordinate.latitude
        globalEvent.eventList = []
        Database.database().reference().child("Events").observe(.childAdded, with: {(snapshot) in
            if let dict = snapshot.value as! [String: AnyObject]?
            {
                let event = Event()
                event.numOfHead = dict["Number of Heads"] as? String
                event.eventName = dict["Event Name"] as? String
                event.eventType = dict["Event Type"] as? String
                event.eventDescription = dict["Event Description"] as? String
                event.long = dict["Longitude"] as? Double
                event.lat = dict["Latitude"] as? Double
                event.uuid = dict["Event UUID"] as? String
                let eventLong = dict["Longitude"] as? Double
                let eventLat = dict["Latitude"] as? Double
                let coordinate₀ = CLLocation(latitude: currentlat, longitude: currentlong)
                let coordinate₁ = CLLocation(latitude: eventLat!, longitude: eventLong!)
                let distanceInMeters = coordinate₀.distance(from: coordinate₁)
                let distanceInMiles = round(10.0 * distanceInMeters * 0.000621371)/10.0
                event.distance = distanceInMiles
                globalEvent.eventList.append(event)
                
            }
        })
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let allAnnotations = self.mapView.annotations
        mapView.removeAnnotations(allAnnotations!)
        var highestScore = 0.0
        var eventNames = [String]()
        var eventTypes = [String]()
        var eventScore = [Double]()
        var searchNames = [String]()
        var searchLat = [Double]()
        var searchLong = [Double]()
        var eventDescription = [String]()
        var eventLat = 0.0
        var eventLong = 0.0
        var eventTitle = ""
        searchTextArr = (searchBar.text?.components(separatedBy: " "))!
        for events in globalEvent.eventList{
            var score = 0.0
            for searchResults in searchTextArr{
                eventNames = (events.eventName?.lowercased().components(separatedBy: " "))!
                eventTypes = (events.eventType?.lowercased().components(separatedBy: " "))!
                eventDescription = (events.eventDescription?.lowercased().components(separatedBy: " "))!
                if(eventNames.contains(searchResults.lowercased())){
                    score = score + 5
                }
                if(eventTypes.contains(searchResults.lowercased())){
                    score = score + 1
                }
                if(eventDescription.contains(searchResults.lowercased())){
                    score = score + 2
                }
                if(score > 0){
                    if(events.distance < 11){
                        score = score + 2
                    }
                    if(events.distance < 31){
                        score = score + 1
                    }
                    if(events.distance < 51){
                        score = score + 0.5
                    }
                    if(events.distance < 101){
                        score = score + 0.3
                    }
                }
                eventTitle = events.uuid!
                eventLat = events.lat!
                eventLong = events.long!
            }
            searchLat.append(eventLat)
            searchLong.append(eventLong)
            searchNames.append(eventTitle)
            eventScore.append(score)
        }
        for score in eventScore{
            if(score > highestScore){
                highestScore = score
            }
        }
        let constant = 10 / highestScore
        var inflatedScores = [Double]()
        for var score in eventScore{
            score = score * constant
            inflatedScores.append(score)
        }
        var i = 0
        for _ in eventScore{
            createAnnotationWithRelevance(long: searchLong[i], lat: searchLat[i], eventTitle: searchNames[i], eventSubtitle: "\(inflatedScores[i])")
            i = i + 1
        }
    }
    func dismissViews() {
        if(searchBar.text == nil){
        let allAnnotations = self.mapView.annotations
        mapView.removeAnnotations(allAnnotations!)
        getEvents()
        }
        view.endEditing(true)
        UIView.animate(withDuration: 1.0, animations: {
            self.popupView.frame.origin.y = self.view.center.y - 100
            self.popupView.alpha = 0
        })
    }
    func getEvents() {
        globalAnnotation.num = 0
        Database.database().reference().child("Events").observeSingleEvent(of: .value, with: { snapshot in
            for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                self.enter = false
                let annotation = Annotation()
                for child in eventID.children.allObjects as! [DataSnapshot] {
                    if(child.key == "Accessibility"){
                        if(child.value as! String == "Public"){
                            self.enter = true
                        }
                    }
                    if(self.enter){
                        if(child.key == "Event UUID"){
                            annotation.eventName = child.value as! String
                        }
                        if(child.key == "Longitude"){
                            annotation.eventLong = child.value as! Double
                        }
                        if(child.key == "Latitude"){
                            annotation.eventLat = child.value as! Double
                        }
                    }
                }
                if(annotation.eventName != ""){
                   globalAnnotation.annotation.append(annotation)
                }
                
            }
            for event in globalAnnotation.annotation{
                globalAnnotation.num += 1
                self.createAnnotation(long: event.eventLong, lat: event.eventLat, eventTitle: event.eventName)
            }
        })
    }
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        if("\(annotation.title!!)" == "You Are Here"){
            let camera = MGLMapCamera(lookingAtCenter: annotation.coordinate, fromDistance: 4000, pitch: 0, heading: 0)
            mapView.setCamera(camera, animated: true)
        }
        else{
        var eventLat = 0.0
        var eventLong = 0.0
        var currentLocation: CLLocation!
        let locManager = CLLocationManager()
        currentLocation = locManager.location
        let currentlong = currentLocation.coordinate.longitude
        let currentlat = currentLocation.coordinate.latitude
        UIView.animate(withDuration: 1.0, animations: {
             self.popupView.frame.origin.y = self.view.center.y
             self.popupView.alpha = 1
        })
        Database.database().reference().child("Events").child("\(annotation.title!!)").observe(.childAdded, with: {(snapshot) in
            if(snapshot.key == "Date"){
                self.eventDate.text = snapshot.value as? String
            }
            if(snapshot.key == "Event Name"){
                self.eventName.text = snapshot.value as? String
            }
            if(snapshot.key == "Start Time"){
                self.eventTime.text = snapshot.value as? String
            }
            if(snapshot.key == "Latitude"){
                 eventLat = snapshot.value as! Double
            }
            if(snapshot.key == "Longitude"){
                eventLong = snapshot.value as! Double
            }
            if(snapshot.key == "Event UUID"){
                self.eventUUID = snapshot.value as! String
            }
            let coordinate₀ = CLLocation(latitude: currentlat, longitude: currentlong)
            let coordinate₁ = CLLocation(latitude: eventLat, longitude: eventLong)
            let distanceInMeters = coordinate₀.distance(from: coordinate₁)
            let distanceInMiles = round(10.0 * distanceInMeters * 0.000621371)/10.0
            self.eventDistance.text = "\(distanceInMiles) miles away"
        })
        let camera = MGLMapCamera(lookingAtCenter: annotation.coordinate, fromDistance: 4000, pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: true)
        }

    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if annotationView == nil {
            annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            annotationView?.alpha = 0
            UIView.animate(withDuration: 0.8, animations: {
                annotationView?.alpha = 1
            })
        }
        
        return annotationView
    }
    func createAnnotation(long: Double, lat: Double, eventTitle: String) {
        let annotation = MGLPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.title = eventTitle
        mapView.addAnnotation(annotation)
    }
    func createAnnotationWithRelevance(long: Double, lat: Double, eventTitle: String, eventSubtitle: String) {
        
        let annotation = MGLPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.title = eventTitle
        annotation.subtitle = eventSubtitle
        mapView.addAnnotation(annotation)
    }
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        
        return false
    }
}
class CustomAnnotationView: MGLAnnotationView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if(globalAnnotation.num > 0){
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: ([.autoreverse]), animations: {() -> Void in
            var frame: CGRect = self.layer.frame
            frame.origin.y -= 8
            self.layer.frame = frame
            //The Alex Manacop Bug
            /*
            ....................../´¯/)
            ....................,/¯../
            .................../..../
            ............./´¯/'...'/´¯¯`·¸
            ........../'/.../..../......./¨¯\
            ........('(...´...´.... ¯~/'...')
            .........\.................'...../
            ..........''...\.......... _.·´
            ............\..............(
            ..............\.............\...
             */
        })
            print(globalAnnotation.num)
            globalAnnotation.num -= 1
        }
        if(annotation?.subtitle! == nil){
            layer.contents = UIImage(named: "RedIcon")?.cgImage
        }
        else{
            if(Double(annotation!.subtitle!!)! > 8.0){
                layer.contents = UIImage(named: "GreenIcon")?.cgImage
            }
            else if(Double(annotation!.subtitle!!)! > 5.0){
                layer.contents = UIImage(named: "OrangeIcon")?.cgImage
            }
            else if(Double(annotation!.subtitle!!)! > 2.0){
                layer.contents = UIImage(named: "YellowIcon")?.cgImage
            }
        }
        scalesWithViewingDistance = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
