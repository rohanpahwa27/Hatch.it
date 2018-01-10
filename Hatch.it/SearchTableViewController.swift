//
//  SearchTableViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 11/25/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
//Global Variables
struct globalEvent{
    static var selectedRow = 0
    static var eventList = [Event]()
    static var filteredEventList = [Event]()
    static var up = false
}
class SearchTableViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    //IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    //Variables and Constants
    let loader = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var ref: DatabaseReference!
    var refHandle: UInt!
    var refresher: UIRefreshControl!
    var isSearching = false
    var sortSpots:[(eventName: String, spots: Int)] = []
    var sortDate = [String]()
    var sortByHeads = false
    var sortByHeads2 = false
    var sortbyDate = false
    var sortDistance = false
    //Functions
    func fetchEvents() {
        if(isSearching){
            globalEvent.filteredEventList = globalEvent.eventList.filter({$0.eventName?.lowercased().range(of: searchBar.text!.lowercased()) != nil})
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        else{
            var currentLocation: CLLocation!
            let locManager = CLLocationManager()
            currentLocation = locManager.location
            let currentlong = currentLocation.coordinate.longitude
            let currentlat = currentLocation.coordinate.latitude
            loader.startAnimating()
            sortByHeads = false
            sortByHeads2 = false
            sortbyDate = false
            sortDistance = false
            globalEvent.eventList = []
            sortDate = []
            ref.child("Events").observe(.childAdded, with: {(snapshot) in
                if let dict = snapshot.value as! [String: AnyObject]?
                {
                    let event = Event()
                    event.eventAddress = dict["Event Address"] as? String
                    event.startTime = dict["Start Time"] as? String
                    event.endTime = dict["End Time"] as? String
                    event.eventName = dict["Event Name"] as? String
                    event.eventType = dict["Event Type"] as? String
                    event.location = dict["Event Location"] as? String
                    event.eventVisibility = dict["Accessibility"] as? String
                    event.numOfHead = dict["Number of Heads"] as? String
                    event.eventDescription = dict["Event Description"] as? String
                    event.eventDate = dict["Date"] as? String
                    event.codedDate = dict["Coded Date"] as? String
                    event.eventImage = dict["Event Image"] as? String
                    event.uuid = dict["Event UUID"] as? String
                    let eventLong = dict["Longitude"] as? Double
                    let eventLat = dict["Latitude"] as? Double
                    let coordinate₀ = CLLocation(latitude: currentlat, longitude: currentlong)
                    let coordinate₁ = CLLocation(latitude: eventLat!, longitude: eventLong!)
                    let distanceInMeters = coordinate₀.distance(from: coordinate₁)
                    let distanceInMiles = round(10.0 * distanceInMeters * 0.000621371)/10.0
                    event.distance = distanceInMiles
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
                        }
                    }
                    if let value = Int(event.numOfHead!){
                        self.sortSpots.append((eventName: event.eventName!, spots: value))
                    }
                    else{
                        self.sortSpots.append((eventName: event.eventName!, spots: 100000000))
                    }
                    self.sortDate.append(event.eventDate!)
                    globalEvent.eventList.append(event)
                    self.loader.stopAnimating()
                    self.tableView.reloadData()
                }
            })
            refresher.endRefreshing()
        }
    }
    func sortByDistance() {
        if(isSearching){
            print(globalEvent.filteredEventList)
            globalEvent.filteredEventList = globalEvent.filteredEventList.sorted(by: {$0.distance < $1.distance})
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        else{
            globalEvent.eventList = []
            globalEvent.filteredEventList = []
            sortDistance = true
            sortbyDate = false
            sortByHeads2 = false
            sortByHeads = false
            var currentLocation: CLLocation!
            let locManager = CLLocationManager()
            currentLocation = locManager.location
            let currentlong = currentLocation.coordinate.longitude
            let currentlat = currentLocation.coordinate.latitude
            refHandle = ref.child("Events").observe(.childAdded, with: {(snapshot) in
                if let dict = snapshot.value as! [String: AnyObject]?
                {
                    let event = Event()
                    event.eventName = dict["Event Name"] as? String
                    event.location = dict["Event Location"] as? String
                    event.eventImage = dict["Event Image"] as? String
                    event.eventVisibility = dict["Accessibility"] as? String
                    event.uuid = dict["Event UUID"] as? String
                    event.eventDate = dict["Date"] as? String
                    event.numOfHead = dict["Number of Heads"] as? String
                    event.eventDescription = dict["Event Description"] as? String
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
                        }
                    }
                    let eventLong = dict["Longitude"] as? Double
                    let eventLat = dict["Latitude"] as? Double
                    let coordinate₀ = CLLocation(latitude: currentlat, longitude: currentlong)
                    let coordinate₁ = CLLocation(latitude: eventLat!, longitude: eventLong!)
                    let distanceInMeters = coordinate₀.distance(from: coordinate₁)
                    let distanceInMiles = round(10.0 * distanceInMeters * 0.000621371)/10.0
                    event.distance = distanceInMiles
                    globalEvent.eventList.append(event)
                    globalEvent.eventList.sort(by: {$0.distance < $1.distance})
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                }
                
            })
        }
    }
    func sortByDate() {
        if(isSearching){
            globalEvent.filteredEventList = globalEvent.filteredEventList.sorted(by: { $0.codedDate!.compare($1.codedDate!) == .orderedAscending })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        else{
            globalEvent.eventList = []
            sortbyDate = true
            sortDistance = false
            sortByHeads = false
            sortByHeads2 = false
            refHandle = ref.child("Events").observe(.childAdded, with: {(snapshot) in
                if let dict = snapshot.value as! [String: AnyObject]?
                {
                    let event = Event()
                    event.eventName = dict["Event Name"] as? String
                    event.uuid = dict["Event UUID"] as? String
                    event.location = dict["Event Location"] as? String
                    event.eventImage = dict["Event Image"] as? String
                    event.codedDate = dict["Coded Date"] as? String
                    event.eventDate = dict["Date"] as? String
                    var currentLocation: CLLocation!
                    let locManager = CLLocationManager()
                    currentLocation = locManager.location
                    let currentlong = currentLocation.coordinate.longitude
                    let currentlat = currentLocation.coordinate.latitude
                    let eventLong = dict["Longitude"] as? Double
                    let eventLat = dict["Latitude"] as? Double
                    let coordinate₀ = CLLocation(latitude: currentlat, longitude: currentlong)
                    let coordinate₁ = CLLocation(latitude: eventLat!, longitude: eventLong!)
                    let distanceInMeters = coordinate₀.distance(from: coordinate₁)
                    let distanceInMiles = round(10.0 * distanceInMeters * 0.000621371)/10.0
                    event.distance = distanceInMiles
                    event.eventVisibility = dict["Accessibility"] as? String
                    event.numOfHead = dict["Number of Heads"] as? String
                    event.eventDescription = dict["Event Description"] as? String
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
                        }
                    }
                    globalEvent.eventList.append(event)
                    globalEvent.eventList.sort(by: { $0.codedDate!.compare($1.codedDate!) == .orderedAscending })
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    func sortBySpotsRemaining() {
        if(isSearching){
            globalEvent.filteredEventList = globalEvent.filteredEventList.sorted(by: { $0.numOfHead!.compare($1.numOfHead!) == .orderedDescending })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        else{
            sortByHeads = true
            sortByHeads2 = false
            sortbyDate = false
            sortDistance = false
            globalEvent.eventList = []
            refHandle = ref.child("Events").observe(.childAdded, with: {(snapshot) in
                if let dict = snapshot.value as! [String: AnyObject]?
                {
                    let event = Event()
                    event.eventName = dict["Event Name"] as? String
                    event.location = dict["Event Location"] as? String
                    event.eventImage = dict["Event Image"] as? String
                    event.eventVisibility = dict["Accessibility"] as? String
                    event.numOfHead = dict["Number of Heads"] as? String
                    var currentLocation: CLLocation!
                    let locManager = CLLocationManager()
                    currentLocation = locManager.location
                    let currentlong = currentLocation.coordinate.longitude
                    let currentlat = currentLocation.coordinate.latitude
                    let eventLong = dict["Longitude"] as? Double
                    let eventLat = dict["Latitude"] as? Double
                    let coordinate₀ = CLLocation(latitude: currentlat, longitude: currentlong)
                    let coordinate₁ = CLLocation(latitude: eventLat!, longitude: eventLong!)
                    let distanceInMeters = coordinate₀.distance(from: coordinate₁)
                    let distanceInMiles = round(10.0 * distanceInMeters * 0.000621371)/10.0
                    event.distance = distanceInMiles
                    event.eventDate = dict["Date"] as? String
                    event.uuid = dict["Event UUID"] as? String
                    event.eventDescription = dict["Event Description"] as? String
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
                        }
                    }
                    globalEvent.eventList.append(event)
                    globalEvent.eventList.sort(by: { $0.numOfHead!.compare($1.numOfHead!) == .orderedDescending })
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    func sortBySpotsRemaining2() {
        if(isSearching){
            globalEvent.filteredEventList = globalEvent.filteredEventList.sorted(by: { $0.numOfHead!.compare($1.numOfHead!) == .orderedAscending })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        else{
            sortByHeads = false
            sortByHeads2 = true
            sortbyDate = false
            sortDistance = false
            globalEvent.eventList = []
            refHandle = ref.child("Events").observe(.childAdded, with: {(snapshot) in
                if let dict = snapshot.value as! [String: AnyObject]?
                {
                    let event = Event()
                    event.eventName = dict["Event Name"] as? String
                    event.location = dict["Event Location"] as? String
                    event.eventImage = dict["Event Image"] as? String
                    event.eventVisibility = dict["Accessibility"] as? String
                    event.numOfHead = dict["Number of Heads"] as? String
                    var currentLocation: CLLocation!
                    let locManager = CLLocationManager()
                    currentLocation = locManager.location
                    let currentlong = currentLocation.coordinate.longitude
                    let currentlat = currentLocation.coordinate.latitude
                    let eventLong = dict["Longitude"] as? Double
                    let eventLat = dict["Latitude"] as? Double
                    let coordinate₀ = CLLocation(latitude: currentlat, longitude: currentlong)
                    let coordinate₁ = CLLocation(latitude: eventLat!, longitude: eventLong!)
                    let distanceInMeters = coordinate₀.distance(from: coordinate₁)
                    let distanceInMiles = round(10.0 * distanceInMeters * 0.000621371)/10.0
                    event.distance = distanceInMiles
                    event.eventDate = dict["Date"] as? String
                    event.uuid = dict["Event UUID"] as? String
                    event.eventDescription = dict["Event Description"] as? String
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
                        }
                    }
                    globalEvent.eventList.append(event)
                    globalEvent.eventList.sort(by: { $0.numOfHead!.compare($1.numOfHead!) == .orderedAscending })
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: "sortBy", sender: self)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text == nil || searchBar.text == ""){
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        }
        else{
            isSearching = true
            globalEvent.filteredEventList = globalEvent.eventList.filter({$0.eventName?.lowercased().range(of: searchBar.text!.lowercased()) != nil})
            tableView.reloadData()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    //Override Functions
    override func viewWillAppear(_ animated: Bool) {
        
        fetchEvents()
        
    }
    override func viewDidLoad() {
        searchBar.setImage(#imageLiteral(resourceName: "FilterIcon"), for: .bookmark, state: .normal)
        tableView.tableFooterView = UIView()
        loader.center = tableView.center
        loader.hidesWhenStopped = true
        view.addSubview(loader)
        super.viewDidLoad()
        self.searchBar.delegate = self
        self.tableView.delegate = self
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull Down to Refresh")
        refresher.addTarget(self, action: #selector(fetchEvents), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        searchBar.returnKeyType = UIReturnKeyType.done
        ref = Database.database().reference()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchEvents), name: NSNotification.Name(rawValue: "callForAlert3"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sortBySpotsRemaining), name: NSNotification.Name(rawValue: "callForAlert4"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sortByDate), name: NSNotification.Name(rawValue: "callForAlert5"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sortByDistance), name: NSNotification.Name(rawValue: "callForAlert6"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sortBySpotsRemaining2), name: NSNotification.Name(rawValue: "callForAlert1"), object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isSearching)
        {
            return globalEvent.filteredEventList.count
        }
        return globalEvent.eventList.count
    }
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()){
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        performSegue(withIdentifier: "eventInfo", sender: self)
        globalEvent.selectedRow = indexPath.row
    }
   
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            cell.transform = CGAffineTransform(translationX: 0, y: 50)
            cell.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0.05*Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellID") as? TableViewCell else {
            return UITableViewCell()
        }
        cell.eventImage.image = nil
        let defaultColor = UIColor.init(red: 206/255, green: 206/255, blue: 206/255, alpha: 1)
        cell.circleOne.backgroundColor = defaultColor
        cell.circleTwo.backgroundColor = defaultColor
        cell.circleThree.backgroundColor = defaultColor
        cell.circleFour.backgroundColor = defaultColor
        cell.circleFive.backgroundColor = defaultColor
        cell.circleSix.backgroundColor = defaultColor
        cell.imageLoader.startAnimating()
        cell.eventImage.layer.cornerRadius = 10
        if(isSearching){
            let url = URL(string: globalEvent.filteredEventList[indexPath.row].eventImage!)
             let session = URLSession(configuration: .default)
             let downloadPicTask = session.dataTask(with: url!) { (data, response, error) in
             if let e = error {
             print(e)
             } else {
             if let res = response as? HTTPURLResponse {
             print(res.statusCode)
             if let imageData = data {
             DispatchQueue.main.async {
             cell.eventImage.image = UIImage(data: imageData)
             cell.imageLoader.stopAnimating()
             }
             }
             }
             }
             }
            
            downloadPicTask.resume()
            cell.eventName.text = globalEvent.filteredEventList[indexPath.row].eventName
            cell.distanceLabel.text = "\(globalEvent.filteredEventList[indexPath.row].distance) mi"
            cell.eventMonth.text = String(describing: globalEvent.filteredEventList[indexPath.row].eventDate!.prefix(3))
            if(globalEvent.filteredEventList[indexPath.row].eventVisibility == "Public"){
                cell.privacyImage.image = #imageLiteral(resourceName: "UnlockedIcon")
            }
            else{
                cell.privacyImage.image = #imageLiteral(resourceName: "LockedIcon")
            }
            let start = globalEvent.filteredEventList[indexPath.row].eventDate?.index(globalEvent.filteredEventList[indexPath.row].eventDate!.startIndex, offsetBy: 4)
            var end = globalEvent.filteredEventList[indexPath.row].eventDate?.index(globalEvent.filteredEventList[indexPath.row].eventDate!.startIndex, offsetBy: 6)
            var range = start..<end
            var subString = globalEvent.filteredEventList[indexPath.row].eventDate![range]
            if String(subString).range(of: ",") != nil{
                end = globalEvent.filteredEventList[indexPath.row].eventDate?.index(globalEvent.filteredEventList[indexPath.row].eventDate!.startIndex, offsetBy: 5)
                range = start..<end
                subString = globalEvent.filteredEventList[indexPath.row].eventDate![range]
                cell.eventDay.text = "0\(String(describing: subString))"
            }
            else{
                cell.eventDay.text = String(subString)
            }
            if globalEvent.filteredEventList[indexPath.row].usersGoing.count == 0 {
                cell.circleOne.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleOneUser.text = ""
                cell.circleTwoUser.text = ""
                cell.circleThreeUser.text = ""
                cell.circleFourUser.text = ""
                cell.circleFiveUser.text = ""
                cell.circleSixUser.text = ""
                cell.circleOne.backgroundColor = UIColor.white
                cell.circleTwo.backgroundColor = UIColor.white
                cell.circleThree.backgroundColor = UIColor.white
                cell.circleFour.backgroundColor = UIColor.white
                cell.circleFive.backgroundColor = UIColor.white
                cell.circleSix.backgroundColor = UIColor.white
                cell.circleOne.layer.borderWidth = 1
                cell.circleTwo.layer.borderWidth = 1
                cell.circleThree.layer.borderWidth = 1
                cell.circleFour.layer.borderWidth = 1
                cell.circleFive.layer.borderWidth = 1
                cell.circleSix.layer.borderWidth = 1
                
            }
            else if globalEvent.filteredEventList[indexPath.row].usersGoing.count == 1{
                cell.circleOne.image = nil
                cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleTwoUser.text = ""
                cell.circleThreeUser.text = ""
                cell.circleFourUser.text = ""
                cell.circleFiveUser.text = ""
                cell.circleSixUser.text = ""
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 1
                cell.circleThree.layer.borderWidth = 1
                cell.circleFour.layer.borderWidth = 1
                
                cell.circleFive.layer.borderWidth = 1
                cell.circleSix.layer.borderWidth = 1
                cell.circleOne.backgroundColor = generateRandomColor()
                cell.circleTwo.backgroundColor = UIColor.white
                cell.circleThree.backgroundColor = UIColor.white
                cell.circleFour.backgroundColor = UIColor.white
                cell.circleFive.backgroundColor = UIColor.white
                cell.circleSix.backgroundColor = UIColor.white
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[0])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                        }
                    }
                    cell.circleOneUser.text = initials
                })
            }
            else if globalEvent.filteredEventList[indexPath.row].usersGoing.count == 2{
                cell.circleOne.image = nil
                cell.circleTwo.image = nil
                cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleThreeUser.text = ""
                cell.circleFourUser.text = ""
                cell.circleFiveUser.text = ""
                cell.circleSixUser.text = ""
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 0
                cell.circleThree.layer.borderWidth = 1
                cell.circleFour.layer.borderWidth = 1
                cell.circleFive.layer.borderWidth = 1
                cell.circleSix.layer.borderWidth = 1
                cell.circleOne.backgroundColor = generateRandomColor()
                cell.circleTwo.backgroundColor = generateRandomColor()
                cell.circleThree.backgroundColor = UIColor.white
                cell.circleFour.backgroundColor = UIColor.white
                cell.circleFive.backgroundColor = UIColor.white
                cell.circleSix.backgroundColor = UIColor.white
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[0])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                        }
                    }
                    cell.circleOneUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[1])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                        }
                    }
                    cell.circleTwoUser.text = initials
                })
                
            }
            else if globalEvent.filteredEventList[indexPath.row].usersGoing.count == 3{
                cell.circleOne.image = nil
                cell.circleTwo.image = nil
                cell.circleThree.image = nil
                cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFourUser.text = ""
                cell.circleFiveUser.text = ""
                cell.circleSixUser.text = ""
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 0
                cell.circleThree.layer.borderWidth = 0
                cell.circleFour.layer.borderWidth = 1
                cell.circleFive.layer.borderWidth = 1
                cell.circleSix.layer.borderWidth = 1
                cell.circleOne.backgroundColor = generateRandomColor()
                cell.circleTwo.backgroundColor = generateRandomColor()
                cell.circleThree.backgroundColor = generateRandomColor()
                cell.circleFour.backgroundColor = UIColor.white
                cell.circleFive.backgroundColor = UIColor.white
                cell.circleSix.backgroundColor = UIColor.white
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[0])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleOneUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[1])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleTwoUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[2])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleThreeUser.text = initials
                })
            }
            else if globalEvent.filteredEventList[indexPath.row].usersGoing.count == 4{
                cell.circleOne.image = nil
                cell.circleTwo.image = nil
                cell.circleThree.image = nil
                cell.circleFour.image = nil
                cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFiveUser.text = ""
                cell.circleSixUser.text = ""
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 0
                cell.circleThree.layer.borderWidth = 0
                cell.circleFour.layer.borderWidth = 0
                cell.circleFive.layer.borderWidth = 1
                cell.circleSix.layer.borderWidth = 1
                cell.circleOne.backgroundColor = generateRandomColor()
                cell.circleTwo.backgroundColor = generateRandomColor()
                cell.circleThree.backgroundColor = generateRandomColor()
                cell.circleFour.backgroundColor = generateRandomColor()
                cell.circleFive.backgroundColor = UIColor.white
                cell.circleSix.backgroundColor = UIColor.white
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[0])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleOneUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[1])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleTwoUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[2])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleThreeUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[3])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleFourUser.text = initials
                })
            }
            else if globalEvent.filteredEventList[indexPath.row].usersGoing.count == 5{
                cell.circleOne.image = nil
                cell.circleTwo.image = nil
                cell.circleThree.image = nil
                cell.circleFour.image = nil
                cell.circleFive.image = nil
                cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleSixUser.text = ""
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 0
                cell.circleThree.layer.borderWidth = 0
                cell.circleFour.layer.borderWidth = 0
                cell.circleFive.layer.borderWidth = 0
                cell.circleSix.layer.borderWidth = 1
                cell.circleOne.backgroundColor = generateRandomColor()
                cell.circleTwo.backgroundColor = generateRandomColor()
                cell.circleThree.backgroundColor = generateRandomColor()
                cell.circleFour.backgroundColor = generateRandomColor()
                cell.circleFive.backgroundColor = generateRandomColor()
                cell.circleSix.backgroundColor = UIColor.white
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[0])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleOneUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[1])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleTwoUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[2])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleThreeUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[3])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleFourUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[4])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleFiveUser.text = initials
                })
            }
            else{
                cell.circleOne.image = nil
                cell.circleTwo.image = nil
                cell.circleThree.image = nil
                cell.circleFour.image = nil
                cell.circleFive.image = nil
                cell.circleSix.image = nil
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 0
                cell.circleThree.layer.borderWidth = 0
                cell.circleFour.layer.borderWidth = 0
                cell.circleFive.layer.borderWidth = 0
                cell.circleSix.layer.borderWidth = 0
                cell.circleOne.backgroundColor = generateRandomColor()
                cell.circleTwo.backgroundColor = generateRandomColor()
                cell.circleThree.backgroundColor = generateRandomColor()
                cell.circleFour.backgroundColor = generateRandomColor()
                cell.circleFive.backgroundColor = generateRandomColor()
                cell.circleSix.backgroundColor = generateRandomColor()
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[0])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleOneUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[1])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleTwoUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[2])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleThreeUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[3])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleFourUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[4])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleFiveUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[indexPath.row].usersGoing[5])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleSixUser.text = initials
                })
            }
        }
        else{
            let url = URL(string: globalEvent.eventList[indexPath.row].eventImage!)
             let session = URLSession(configuration: .default)
             let downloadPicTask = session.dataTask(with: url!) { (data, response, error) in
             if let e = error {
             print(e)
             } else {
             if let res = response as? HTTPURLResponse {
             print(res.statusCode)
             if let imageData = data {
             DispatchQueue.main.async {
             cell.eventImage.image = UIImage(data: imageData)
             cell.imageLoader.stopAnimating()
             }
             }
             }
             }
             }
            
            downloadPicTask.resume()
            let start = globalEvent.eventList[indexPath.row].eventDate?.index(globalEvent.eventList[indexPath.row].eventDate!.startIndex, offsetBy: 4)
            var end = globalEvent.eventList[indexPath.row].eventDate?.index(globalEvent.eventList[indexPath.row].eventDate!.startIndex, offsetBy: 6)
            var range = start..<end
            var subString = globalEvent.eventList[indexPath.row].eventDate![range]
            if String(subString).range(of: ",") != nil
            {
                end = globalEvent.eventList[indexPath.row].eventDate?.index(globalEvent.eventList[indexPath.row].eventDate!.startIndex, offsetBy: 5)
                range = start..<end
                subString = globalEvent.eventList[indexPath.row].eventDate![range]
                cell.eventDay.text = "0\(String(describing: subString))"
            }
            else{
                cell.eventDay.text = String(subString)
            }
            cell.eventName.text = globalEvent.eventList[indexPath.row].eventName
            
            cell.distanceLabel.text = "\(globalEvent.eventList[indexPath.row].distance) mi"
            cell.eventMonth.text = String(describing: globalEvent.eventList[indexPath.row].eventDate!.prefix(3))
            if(globalEvent.eventList[indexPath.row].eventVisibility == "Public"){
                cell.privacyImage.image = #imageLiteral(resourceName: "UnlockedIcon")
            }
            else{
                cell.privacyImage.image = #imageLiteral(resourceName: "LockedIcon")
            }
            if globalEvent.eventList[indexPath.row].usersGoing.count == 0{
                cell.circleOne.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleOneUser.text = ""
                cell.circleTwoUser.text = ""
                cell.circleThreeUser.text = ""
                cell.circleFourUser.text = ""
                cell.circleFiveUser.text = ""
                cell.circleSixUser.text = ""
                cell.circleOne.backgroundColor = UIColor.white
                cell.circleTwo.backgroundColor = UIColor.white
                cell.circleThree.backgroundColor = UIColor.white
                cell.circleFour.backgroundColor = UIColor.white
                cell.circleFive.backgroundColor = UIColor.white
                cell.circleSix.backgroundColor = UIColor.white
                cell.circleOne.layer.borderWidth = 1
                cell.circleTwo.layer.borderWidth = 1
                cell.circleThree.layer.borderWidth = 1
                cell.circleFour.layer.borderWidth = 1
                cell.circleFive.layer.borderWidth = 1
                cell.circleSix.layer.borderWidth = 1
                
            }
            else if globalEvent.eventList[indexPath.row].usersGoing.count == 1{
                cell.circleOne.image = nil
                cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleTwoUser.text = ""
                cell.circleThreeUser.text = ""
                cell.circleFourUser.text = ""
                cell.circleFiveUser.text = ""
                cell.circleSixUser.text = ""
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 1
                cell.circleThree.layer.borderWidth = 1
                cell.circleFour.layer.borderWidth = 1
                
                cell.circleFive.layer.borderWidth = 1
                cell.circleSix.layer.borderWidth = 1
                cell.circleOne.backgroundColor = generateRandomColor()
                cell.circleTwo.backgroundColor = UIColor.white
                cell.circleThree.backgroundColor = UIColor.white
                cell.circleFour.backgroundColor = UIColor.white
                cell.circleFive.backgroundColor = UIColor.white
                cell.circleSix.backgroundColor = UIColor.white
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[0])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleOneUser.text = initials
                })
            }
            else if globalEvent.eventList[indexPath.row].usersGoing.count == 2{
                cell.circleOne.image = nil
                cell.circleTwo.image = nil
                cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleThreeUser.text = ""
                cell.circleFourUser.text = ""
                cell.circleFiveUser.text = ""
                cell.circleSixUser.text = ""
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 0
                cell.circleThree.layer.borderWidth = 1
                cell.circleFour.layer.borderWidth = 1
                cell.circleFive.layer.borderWidth = 1
                cell.circleSix.layer.borderWidth = 1
                cell.circleOne.backgroundColor = generateRandomColor()
                cell.circleTwo.backgroundColor = generateRandomColor()
                cell.circleThree.backgroundColor = UIColor.white
                cell.circleFour.backgroundColor = UIColor.white
                cell.circleFive.backgroundColor = UIColor.white
                cell.circleSix.backgroundColor = UIColor.white
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[0])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleOneUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[1])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleTwoUser.text = initials
                })
                
            }
            else if globalEvent.eventList[indexPath.row].usersGoing.count == 3{
                cell.circleOne.image = nil
                cell.circleTwo.image = nil
                cell.circleThree.image = nil
                cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFourUser.text = ""
                cell.circleFiveUser.text = ""
                cell.circleSixUser.text = ""
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 0
                cell.circleThree.layer.borderWidth = 0
                cell.circleFour.layer.borderWidth = 1
                cell.circleFive.layer.borderWidth = 1
                cell.circleSix.layer.borderWidth = 1
                cell.circleOne.backgroundColor = generateRandomColor()
                cell.circleTwo.backgroundColor = generateRandomColor()
                cell.circleThree.backgroundColor = generateRandomColor()
                cell.circleFour.backgroundColor = UIColor.white
                cell.circleFive.backgroundColor = UIColor.white
                cell.circleSix.backgroundColor = UIColor.white
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[0])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleOneUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[1])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleTwoUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[2])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleThreeUser.text = initials
                })
            }
            else if globalEvent.eventList[indexPath.row].usersGoing.count == 4{
                cell.circleOne.image = nil
                cell.circleTwo.image = nil
                cell.circleThree.image = nil
                cell.circleFour.image = nil
                cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleFiveUser.text = ""
                cell.circleSixUser.text = ""
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 0
                cell.circleThree.layer.borderWidth = 0
                cell.circleFour.layer.borderWidth = 0
                cell.circleFive.layer.borderWidth = 1
                cell.circleSix.layer.borderWidth = 1
                cell.circleOne.backgroundColor = generateRandomColor()
                cell.circleTwo.backgroundColor = generateRandomColor()
                cell.circleThree.backgroundColor = generateRandomColor()
                cell.circleFour.backgroundColor = generateRandomColor()
                cell.circleFive.backgroundColor = UIColor.white
                cell.circleSix.backgroundColor = UIColor.white
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[0])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleOneUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[1])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleTwoUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[2])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleThreeUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[3])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleFourUser.text = initials
                })
            }
            else if globalEvent.eventList[indexPath.row].usersGoing.count == 5{
                cell.circleOne.image = nil
                cell.circleTwo.image = nil
                cell.circleThree.image = nil
                cell.circleFour.image = nil
                cell.circleFive.image = nil
                cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                cell.circleSixUser.text = ""
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 0
                cell.circleThree.layer.borderWidth = 0
                cell.circleFour.layer.borderWidth = 0
                cell.circleFive.layer.borderWidth = 0
                cell.circleSix.layer.borderWidth = 1
                cell.circleOne.backgroundColor = generateRandomColor()
                cell.circleTwo.backgroundColor = generateRandomColor()
                cell.circleThree.backgroundColor = generateRandomColor()
                cell.circleFour.backgroundColor = generateRandomColor()
                cell.circleFive.backgroundColor = generateRandomColor()
                cell.circleSix.backgroundColor = UIColor.white
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[0])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleOneUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[1])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleTwoUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[2])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleThreeUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[3])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleFourUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[4])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleFiveUser.text = initials
                })
            }
            else{
                cell.circleOne.image = nil
                cell.circleTwo.image = nil
                cell.circleThree.image = nil
                cell.circleFour.image = nil
                cell.circleFive.image = nil
                cell.circleSix.image = nil
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 0
                cell.circleThree.layer.borderWidth = 0
                cell.circleFour.layer.borderWidth = 0
                cell.circleFive.layer.borderWidth = 0
                cell.circleSix.layer.borderWidth = 0
                cell.circleOne.backgroundColor = generateRandomColor()
                cell.circleTwo.backgroundColor = generateRandomColor()
                cell.circleThree.backgroundColor = generateRandomColor()
                cell.circleFour.backgroundColor = generateRandomColor()
                cell.circleFive.backgroundColor = generateRandomColor()
                cell.circleSix.backgroundColor = generateRandomColor()
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[0])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleOneUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[1])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleTwoUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[2])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleThreeUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[3])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleFourUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[4])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleFiveUser.text = initials
                })
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    var firstName = ""
                    var lastName = ""
                    var initials = ""
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[indexPath.row].usersGoing[5])
                        {
                            for child in eventID.children.allObjects as! [DataSnapshot] {
                                if(child.key == "First Name")
                                {
                                    firstName = child.value as! String
                                    initials = String(firstName.prefix(1))
                                }
                                if(child.key == "Last Name")
                                {
                                    lastName = child.value as! String
                                    initials = initials + String(lastName.prefix(1))
                                }
                            }
                            
                        }
                        
                    }
                    cell.circleSixUser.text = initials
                })
            }
        }
        return cell
    }
}
