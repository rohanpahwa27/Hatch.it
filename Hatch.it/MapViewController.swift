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
class MapViewController: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate {
    
    //IBOutlets
    @IBOutlet weak var currentLocationB: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBAction func currentLocation(_ sender: UIButton) {
        let locManager = CLLocationManager()
        let lat = locManager.location?.coordinate.latitude
        let long = locManager.location?.coordinate.longitude
        mapView.setCenter(CLLocationCoordinate2D(latitude: lat!, longitude: long!), zoomLevel: 9, animated: true)
    }
    //Variables and Constants
    var mapView = MGLMapView()
    var eventID: String?
    var relevantEvents:[(eventID: String, relevance: Int)] = []
    var ref: DatabaseReference!
    var eventNames = [String]()
    var eventSubtitles = [String]()
    var eventLong = [Double]()
    var eventLat = [Double]()
    var enter = false
    //Override Functions
    override func viewWillAppear(_ animated: Bool) {
        getEvents()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.init(red: 225/255, green: 201/255, blue: 222/255, alpha: 1)
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
                backgroundview.layer.cornerRadius = 14;
                backgroundview.clipsToBounds = true;
            }
        }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //Functions/
    func getEvents() {
        Database.database().reference().child("Events").observeSingleEvent(of: .value, with: { snapshot in
            for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                self.enter = false
                for child in eventID.children.allObjects as! [DataSnapshot] {
                    if(child.key == "Accessibility"){
                        if(child.value as! String == "Public"){
                            self.enter = true
                        }
                    }
                    if(self.enter){
                        if(child.key == "Event Name"){
                            self.eventNames.append(child.value as! String)
                        }
                        if(child.key == "Event Type"){
                            self.eventSubtitles.append(child.value as! String)
                        }
                        if(child.key == "Longitude"){
                            self.eventLong.append(child.value as! Double)
                        }
                        if(child.key == "Latitude"){
                            self.eventLat.append(child.value as! Double)
                        }
                    }
                    
                }
                
            }
            var i: Int = 0
            for events in self.eventNames{
                self.createAnnotation(long: self.eventLong[i], lat: self.eventLat[i], eventTitle: events, eventSubtitle: self.eventSubtitles[i])
                i += 1
            }
        })
    }
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        let camera = MGLMapCamera(lookingAtCenter: annotation.coordinate, fromDistance: 4000, pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: true)
    }
    func dismissKeyboard() {
        view.endEditing(true)
        let keywordSearch = searchBar.text?.components(separatedBy: " ")
        reloadEvents(keywordSearch: keywordSearch)
    }
    func reloadEvents(keywordSearch: [String]?)
    {
        var relevance: Int = 0
        Database.database().reference().child("Events").observeSingleEvent(of: .value, with: { snapshot in
            for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                for child in eventID.children.allObjects as! [DataSnapshot] {
                    if(child.key == "Event Name"){
                        for keywords in keywordSearch! {
                            if(child.value as! String == keywords){
                                relevance += 1
                            }
                        }
                    }
                    if(child.key == "Event Type"){
                        for keywords in keywordSearch! {
                            if(child.value as! String == keywords){
                                relevance += 1
                            }
                        }
                    }
                    if(child.key == "Event Description"){
                        for keywords in keywordSearch! {
                            if(child.value as! String == keywords){
                                relevance += 1
                            }
                        }
                    }
                }
                
                self.relevantEvents.append((eventID: eventID.key, relevance: relevance))
            }
        })
    }
    func createAnnotation(long: Double, lat: Double, eventTitle: String, eventSubtitle: String) {
        let annotation = MGLPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.title = eventTitle
        annotation.subtitle = eventSubtitle
        mapView.addAnnotation(annotation)
    }
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}
