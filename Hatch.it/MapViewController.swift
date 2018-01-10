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
struct globalAnnotation{
    static var annotation = [Annotation]()
}
class MapViewController: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate, UISearchBarDelegate {
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
    @IBOutlet weak var currentLocationB: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBAction func currentLocation(_ sender: UIButton) {
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
        getEvents()
        fetchEvents()
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
        let locManager = CLLocationManager()
        currentLocationB.layer.borderWidth = 1
        currentLocationB.layer.borderColor = UIColor.black.cgColor
        currentLocationB.layer.cornerRadius = 10
        let url = URL(string: "mapbox://styles/stephenth0ma5/cjayeqlub44lh2qqyzmmpynhc")
        let lat = locManager.location?.coordinate.latitude
        let long = locManager.location?.coordinate.longitude
        mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.delegate = self
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.showsUserLocation = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: lat!, longitude: long!), zoomLevel: 9, animated: false)
        view.addSubview(mapView)
        view.addSubview(searchBar)
        view.addSubview(currentLocationB)
        view.bringSubview(toFront: popupView)
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
                backgroundview.layer.cornerRadius = 14;
                backgroundview.clipsToBounds = true;
            }
        }
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
        var highestScore = 0.0
        let allAnnotations = self.mapView.annotations
        mapView.removeAnnotations(allAnnotations!)
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
                print(score)
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
        // This example is only concerned with point annotations.
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            annotationView?.alpha = 0
            UIView.animate(withDuration: 1.0, animations: {
                annotationView?.alpha = 1
            })
            // Set the annotation view’s background color to a value determined by its longitude.
            annotationView!.backgroundColor = UIColor.red
        }
        
        return annotationView
    }
    /*func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage?
    {
        if(annotation.subtitle! == nil){
            let annotationImage = MGLAnnotationImage(image: #imageLiteral(resourceName: "RedIcon"), reuseIdentifier: "Red")
            return annotationImage
        }
        else{
        if(Double(annotation.subtitle!!)! > 8.0){
            let annotationImage = MGLAnnotationImage(image: #imageLiteral(resourceName: "GreenIcon"), reuseIdentifier: "Green")
            return annotationImage
        }
        if(Double(annotation.subtitle!!)! > 5.0){
            let annotationImage = MGLAnnotationImage(image: #imageLiteral(resourceName: "Orange Icon"), reuseIdentifier: "Orange")
            return annotationImage
        }
        if(Double(annotation.subtitle!!)! > 2.0){
            let annotationImage = MGLAnnotationImage(image: #imageLiteral(resourceName: "YellowIcon"), reuseIdentifier: "Yellow")
            return annotationImage
        }
        let annotationImage = MGLAnnotationImage(image: #imageLiteral(resourceName: "RedIcon"), reuseIdentifier: "Red")
        return annotationImage
        }
    }*/
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
        
        // Force the annotation view to maintain a constant size when the map is tilted.
        scalesWithViewingDistance = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
