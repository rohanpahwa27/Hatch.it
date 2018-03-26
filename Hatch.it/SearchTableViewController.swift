//
//  SearchTableViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 11/25/17.
//  Copyright © 2017 RITE Apps LLC All rights reserved.
//

import UIKit
import AudioToolbox
import Firebase
import CoreLocation
//Global Variables
struct globalEvent{
    static var selectedRow = 0
    static var eventList = [Event]()
    static var filteredEventList = [Event]()
    static var up = false
    static var searching = false
    static var interestsArr = [String]()
    static var sort = false
}
class SearchTableViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    //IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    let noEventsFound = UILabel()
    //Variables and Constants
    let loader = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var ref: DatabaseReference!
    var refHandle: UInt!
    var refresher: UIRefreshControl!
    var isSearching = false
    var sortDate = [String]()
    var colorArr = [UIColor]()
    var eventScore = [Int]()
    var sortSpots = false
    var sortSpots2 = false
    var sortDates = false
    var sortDistance = false
    //Functions
    func fetchInterests() {
        globalEvent.interestsArr = []
        var count: UInt?
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).observe(.childAdded, with: { (snapshot) in
            if(snapshot.key == "Interests"){
                count = snapshot.childrenCount
                for child in snapshot.children.allObjects as! [DataSnapshot]{
                    globalEvent.interestsArr.append(child.value as! String)
                }
            }
            if(UInt(globalEvent.interestsArr.count) == count){
                Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).removeAllObservers()
                self.sortByRelevancy()
            }
        })
    }
    func sortByRelevancy() {
        eventScore = []
        if(globalEvent.searching){
            for event in globalEvent.filteredEventList{
                var score = 0
                for interests in globalEvent.interestsArr{
                    if(event.eventName?.lowercased().range(of: interests.lowercased()) != nil){
                        score += 10
                    }
                    if(event.eventDescription?.lowercased().range(of: interests.lowercased()) != nil){
                        score += 5
                    }
                }
                event.score = score
            }
            DispatchQueue.main.async {
                globalEvent.filteredEventList.sort(by: {$0.score > $1.score})
                sleep(1)
                self.tableView.reloadData()
                self.refresher.endRefreshing()
            }
        }
        else{
            for event in globalEvent.eventList{
                var score = 0
                for interests in globalEvent.interestsArr{
                    if(event.eventName?.lowercased().range(of: interests.lowercased()) != nil){
                        score += 10
                    }
                    if(event.eventDescription?.lowercased().range(of: interests.lowercased()) != nil){
                        score += 5
                    }
                }
                event.score = score
            }
        }
        //globalEvent.eventList.sort(by: {$0.score > $1.score})
        DispatchQueue.main.async {
        //globalEvent.eventList.sort(by: {$0.score > $1.score})
        //sleep(1)
        self.tableView.reloadData()
        self.refresher.endRefreshing()
        }
    }
    func fetchEvents() {
        sortDates = false
        sortSpots2 = false
        sortSpots = false
        sortDistance = false
        if(isSearching){
            globalEvent.filteredEventList = globalEvent.eventList.filter({$0.eventName?.lowercased().range(of: searchBar.text!.lowercased()) != nil})
            DispatchQueue.main.async {
                self.filterDistance()
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
            globalEvent.eventList = []
            sortDate = []
            Database.database().reference().child("Events").observe(.childAdded, with: {(snapshot) in
                if let dict = snapshot.value as! [String: AnyObject]?
                {
                    var usersGoing = 0
                    var numOfHead = 0
                    let event = Event()
                    event.eventAddress = dict["Event Address"] as? String
                    event.startTime = dict["Start Time"] as? String
                    event.endTime = dict["End Time"] as? String
                    event.eventName = dict["Event Name"] as? String
                    event.eventType = dict["Event Type"] as? String
                    event.location = dict["Event Location"] as? String
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
                    event.codedDate = dict["Coded Date"] as? String
                    event.eventImage = dict["Event Image"] as? String
                    event.uuid = dict["Event UUID"] as? String
                    event.long = dict["Longitude"] as? Double
                    event.lat = dict["Latitude"] as? Double
                    event.host = dict["Host"] as? String
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
                            usersGoing = event.usersGoing.count
                        }
                        else if(events.key == "Requested Users"){
                            for users in events.children.allObjects as! [DataSnapshot]{
                                event.requestedUsers.append(users.value as! String)
                            }
                        }
                    }
                    event.numOfHead = "\(numOfHead - usersGoing)"
                    self.sortDate.append(event.eventDate!)
                    let d1 = DateFormatter()
                    d1.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                    let date = d1.date(from: event.codedDate!)
                    if(date!.timeIntervalSinceNow > 0){
                        globalEvent.eventList.append(event)
                    }
                    self.loader.stopAnimating()
                    
                    DispatchQueue.main.async {
                        self.fetchInterests()
                        self.filterDistance()
                        //self.tableView.reloadData()
                    }
                }
            })
            refresher.endRefreshing()
        }
    }
    func sortByDistance() {
        sortDistance = true
        sortSpots = false
        sortSpots2 = false
        sortDates = false
        if(isSearching){
            globalEvent.filteredEventList = globalEvent.filteredEventList.sorted(by: {$0.distance < $1.distance})
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        else{
            globalEvent.eventList.sort(by: {$0.distance < $1.distance})
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
    }
    func sortByDate() {
        sortDistance = false
        sortSpots = false
        sortSpots2 = false
        sortDates = true
        if(isSearching){
            globalEvent.filteredEventList = globalEvent.filteredEventList.sorted(by: { $0.codedDate!.compare($1.codedDate!) == .orderedAscending })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        else{
            globalEvent.eventList.sort(by: { $0.codedDate!.compare($1.codedDate!) == .orderedAscending })
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
    }
    func sortBySpotsRemaining() {
        sortDistance = false
        sortSpots = true
        sortSpots2 = false
        sortDates = false
        if(isSearching){
            globalEvent.filteredEventList.sort(by: {Int($0.numOfHead!)! > Int($1.numOfHead!)!})
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        else{
            globalEvent.eventList.sort(by: {Int($0.numOfHead!)! > Int($1.numOfHead!)!})
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
    }
    func sortBySpotsRemaining2() {
        sortDistance = false
        sortSpots = false
        sortSpots2 = true
        sortDates = false
        if(isSearching){
            globalEvent.filteredEventList.sort(by: {Int($0.numOfHead!)! < Int($1.numOfHead!)!})
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        else{
            globalEvent.eventList.sort(by: {Int($0.numOfHead!)! < Int($1.numOfHead!)!})
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
    }
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        AudioServicesPlaySystemSound(1519)
        performSegue(withIdentifier: "sortBy", sender: self)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text == nil || searchBar.text == ""){
            globalEvent.searching = false
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        }
        else{
            globalEvent.searching = true
            isSearching = true
            globalEvent.filteredEventList = globalEvent.eventList.filter({$0.eventName?.lowercased().range(of: searchBar.text!.lowercased()) != nil})
            tableView.reloadData()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    func filterDistance() {
        if(globalEvent.searching){
            for events in globalEvent.filteredEventList{
                if events.distance > open.slider {
                    if let index = globalEvent.filteredEventList.index(of: events) {
                        globalEvent.filteredEventList.remove(at: index)
                    }
                }
            }
        }
        else{
            for events in globalEvent.eventList{
                if events.distance > open.slider {
                    if let index = globalEvent.eventList.index(of: events) {
                        globalEvent.eventList.remove(at: index)
                    }
                }
            }
        }
        tableView.reloadData()
    }
    func fetch() {
        variables.event = []
        Database.database().reference().child("Events").observe(.childAdded, with: {(snapshot) in
            if(snapshot.key == values.uuid){
            var usersGoing = 0
            var numOfHead = 0
            let event = Event()
            for events in snapshot.children.allObjects as! [DataSnapshot]{
                if(events.key == "Accessibility"){
                    event.eventVisibility = events.value as? String
                }
                if(events.key == "Coded Date"){
                    event.codedDate = events.value as? String
                }
                if(events.key == "Date"){
                    event.eventDate = events.value as? String
                }
                if(events.key == "End Time"){
                    event.endTime = events.value as? String
                }
                if(events.key == "Event Address"){
                    event.eventAddress = events.value as? String
                }
                if(events.key == "Event Description"){
                    event.eventDescription = events.value as? String
                }
                if(events.key == "Event Image"){
                    event.eventImage = events.value as? String
                }
                if(events.key == "Event Location"){
                    event.location = events.value as? String
                }
                if(events.key == "Event Name"){
                    event.eventName = events.value as? String
                }
                
                if(events.key == "Event UUID"){
                    event.uuid = events.value as? String
                }
                if(events.key == "Host"){
                    event.host = events.value as? String
                }
                
                if(events.key == "Interested Users"){
                    for users in events.children.allObjects as! [DataSnapshot]{
                        event.interestedUsers.append(users.value as! String)
                    }
                }
                if(events.key == "Latitude"){
                    event.lat = events.value as? Double
                }
                if(events.key == "Longitude"){
                    event.long = events.value as? Double
                }
                if(events.key == "Number of Heads"){
                    event.numOfHead = events.value as? String
                    if(events.value as? String == "Unlimited"){
                        numOfHead = Int.max
                    }
                    else{
                        numOfHead = Int(events.value as! String)!
                    }
                }
                if(events.key == "Start Time"){
                    event.startTime = events.value as? String
                }
                if(events.key == "Users Going"){
                    for users in events.children.allObjects as! [DataSnapshot]{
                        event.usersGoing.append(users.value as! String)
                    }
                    usersGoing = event.usersGoing.count
                }
                event.numOfHead = "\(numOfHead - usersGoing)"
            }
                variables.event.append(event)
                self.performSegue(withIdentifier: "eventInfo", sender: self)
            }
        })
    }
    //Override Functions
    override func viewWillAppear(_ animated: Bool) {
        if(!values.link){
            tableView.dataSource = self
        }
        else{
            tableView.dataSource = nil
        }
        if(values.link){
            fetch()
        }
        if(sortDates){
            sortByDate()
        }
        else if(sortSpots2){
            sortBySpotsRemaining2()
        }
        else if(sortSpots){
            sortBySpotsRemaining()
        }
        else if(sortDistance){
            sortByDistance()
        }
        else{
            fetchEvents()
        }
        variables.check = false
        variables.attended = false
        variables.link = false
    }
    override func viewDidLoad() {
        if(!values.link){
            performSegue(withIdentifier: "loading", sender: self)
        }
        sortDates = false
        sortSpots2 = false
        sortSpots = false
        sortDistance = false
        noEventsFound.alpha = 0
        noEventsFound.font = UIFont(name: "Lato-Thin", size: 20)
        noEventsFound.textAlignment = .center
        noEventsFound.text = "No Events Found"
        noEventsFound.center = tableView.center
        tableView.backgroundView = noEventsFound
        colorArr.append(UIColor(red: 101/255, green: 98/255, blue: 190/255, alpha: 0.5))
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
        NotificationCenter.default.addObserver(self, selector: #selector(filterDistance), name: NSNotification.Name(rawValue: "callForAlert7"), object: nil)
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
            if(globalEvent.filteredEventList.count == 0){
                noEventsFound.alpha = 1
            }
            else{
                noEventsFound.alpha = 0
            }
            return globalEvent.filteredEventList.count
        }
        if(globalEvent.eventList.count == 0){
            noEventsFound.alpha = 1
        }
        else{
            noEventsFound.alpha = 0
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
        globalEvent.selectedRow = indexPath.row
        variables.chain.append(globalEvent.eventList[globalEvent.selectedRow])
        print(variables.chain)
        performSegue(withIdentifier: "eventInfo", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(translationX: 0, y: 50)
        cell.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0.05 * Double(indexPath.row), options: [.curveEaseInOut], animations: {
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
                if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 1){
                    cell.circleOne.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleTwo.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleThree.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 2){
                    cell.circleOne.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 3){
                    cell.circleOne.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 4){
                    cell.circleOne.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 5){
                    cell.circleOne.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else{
                    cell.circleOne.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                }
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
                if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 1){
                    cell.circleTwo.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleThree.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 2){
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 3){
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 4){
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 5){
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else{
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                }
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
                let randomIndex = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleOne.backgroundColor = colorArr[randomIndex]
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
                if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 2){
                    cell.circleThree.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 3){
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 4){
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 5){
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else{
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                }
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
                let randomIndex = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleOne.backgroundColor = colorArr[randomIndex]
                let randomIndex2 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleTwo.backgroundColor = colorArr[randomIndex2]
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
                if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 3){
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 4){
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 5){
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else{
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                }
                cell.circleFourUser.text = ""
                cell.circleFiveUser.text = ""
                cell.circleSixUser.text = ""
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 0
                cell.circleThree.layer.borderWidth = 0
                cell.circleFour.layer.borderWidth = 1
                cell.circleFive.layer.borderWidth = 1
                cell.circleSix.layer.borderWidth = 1
                let randomIndex = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleOne.backgroundColor = colorArr[randomIndex]
                let randomIndex2 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleTwo.backgroundColor = colorArr[randomIndex2]
                let randomIndex3 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleThree.backgroundColor = colorArr[randomIndex3]
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
                if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 4){
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 5){
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else{
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                }
                cell.circleFiveUser.text = ""
                cell.circleSixUser.text = ""
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 0
                cell.circleThree.layer.borderWidth = 0
                cell.circleFour.layer.borderWidth = 0
                cell.circleFive.layer.borderWidth = 1
                cell.circleSix.layer.borderWidth = 1
                let randomIndex = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleOne.backgroundColor = colorArr[randomIndex]
                let randomIndex2 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleTwo.backgroundColor = colorArr[randomIndex2]
                let randomIndex3 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleThree.backgroundColor = colorArr[randomIndex3]
                let randomIndex4 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleFour.backgroundColor = colorArr[randomIndex4]
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
                if(Int(globalEvent.filteredEventList[indexPath.row].numOfHead!)! + globalEvent.filteredEventList[indexPath.row].usersGoing.count == 5){
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else{
                    cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                }
                cell.circleSixUser.text = ""
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 0
                cell.circleThree.layer.borderWidth = 0
                cell.circleFour.layer.borderWidth = 0
                cell.circleFive.layer.borderWidth = 0
                cell.circleSix.layer.borderWidth = 1
                let randomIndex = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleOne.backgroundColor = colorArr[randomIndex]
                let randomIndex2 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleTwo.backgroundColor = colorArr[randomIndex2]
                let randomIndex3 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleThree.backgroundColor = colorArr[randomIndex3]
                let randomIndex4 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleFour.backgroundColor = colorArr[randomIndex4]
                let randomIndex5 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleFive.backgroundColor = colorArr[randomIndex5]
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
                let randomIndex = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleOne.backgroundColor = colorArr[randomIndex]
                let randomIndex2 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleTwo.backgroundColor = colorArr[randomIndex2]
                let randomIndex3 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleThree.backgroundColor = colorArr[randomIndex3]
                let randomIndex4 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleFour.backgroundColor = colorArr[randomIndex4]
                let randomIndex5 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleFive.backgroundColor = colorArr[randomIndex5]
                let randomIndex6 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleSix.backgroundColor = colorArr[randomIndex6]
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
                if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 1){
                    cell.circleOne.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleTwo.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleThree.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 2){
                    cell.circleOne.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 3){
                    cell.circleOne.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 4){
                    cell.circleOne.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 5){
                    cell.circleOne.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else{
                    cell.circleOne.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                }
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
                if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 1){
                    cell.circleTwo.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleThree.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 2){
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 3){
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 4){
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 5){
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else{
                    cell.circleTwo.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                }
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
                let randomIndex = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleOne.backgroundColor = colorArr[randomIndex]
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
                        print(indexPath.row)
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
                if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 2){
                    cell.circleThree.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 3){
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 4){
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 5){
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else{
                    cell.circleThree.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                }
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
                let randomIndex = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleOne.backgroundColor = colorArr[randomIndex]
                let randomIndex2 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleTwo.backgroundColor = colorArr[randomIndex2]
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
                if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 3){
                    cell.circleFour.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 4){
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 5){
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else{
                    cell.circleFour.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                }
                cell.circleFourUser.text = ""
                cell.circleFiveUser.text = ""
                cell.circleSixUser.text = ""
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 0
                cell.circleThree.layer.borderWidth = 0
                cell.circleFour.layer.borderWidth = 1
                cell.circleFive.layer.borderWidth = 1
                cell.circleSix.layer.borderWidth = 1
                let randomIndex = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleOne.backgroundColor = colorArr[randomIndex]
                let randomIndex2 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleTwo.backgroundColor = colorArr[randomIndex2]
                let randomIndex3 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleThree.backgroundColor = colorArr[randomIndex3]
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
                if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 4){
                    cell.circleFive.image = #imageLiteral(resourceName: "XIcon")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 5){
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else{
                    cell.circleFive.image = #imageLiteral(resourceName: "PlaceholderPlus")
                    cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                }
                cell.circleFiveUser.text = ""
                cell.circleSixUser.text = ""
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 0
                cell.circleThree.layer.borderWidth = 0
                cell.circleFour.layer.borderWidth = 0
                cell.circleFive.layer.borderWidth = 1
                cell.circleSix.layer.borderWidth = 1
                let randomIndex = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleOne.backgroundColor = colorArr[randomIndex]
                let randomIndex2 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleTwo.backgroundColor = colorArr[randomIndex2]
                let randomIndex3 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleThree.backgroundColor = colorArr[randomIndex3]
                let randomIndex4 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleFour.backgroundColor = colorArr[randomIndex4]
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
                if(Int(globalEvent.eventList[indexPath.row].numOfHead!)! + globalEvent.eventList[indexPath.row].usersGoing.count == 5){
                    cell.circleSix.image = #imageLiteral(resourceName: "XIcon")
                }
                else{
                    cell.circleSix.image = #imageLiteral(resourceName: "PlaceholderPlus")
                }
                cell.circleSixUser.text = ""
                cell.circleOne.layer.borderWidth = 0
                cell.circleTwo.layer.borderWidth = 0
                cell.circleThree.layer.borderWidth = 0
                cell.circleFour.layer.borderWidth = 0
                cell.circleFive.layer.borderWidth = 0
                cell.circleSix.layer.borderWidth = 1
                let randomIndex = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleOne.backgroundColor = colorArr[randomIndex]
                let randomIndex2 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleTwo.backgroundColor = colorArr[randomIndex2]
                let randomIndex3 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleThree.backgroundColor = colorArr[randomIndex3]
                let randomIndex4 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleFour.backgroundColor = colorArr[randomIndex4]
                let randomIndex5 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleFive.backgroundColor = colorArr[randomIndex5]
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
                let randomIndex = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleOne.backgroundColor = colorArr[randomIndex]
                let randomIndex2 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleTwo.backgroundColor = colorArr[randomIndex2]
                let randomIndex3 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleThree.backgroundColor = colorArr[randomIndex3]
                let randomIndex4 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleFour.backgroundColor = colorArr[randomIndex4]
                let randomIndex5 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleFive.backgroundColor = colorArr[randomIndex5]
                let randomIndex6 = Int(arc4random_uniform(UInt32(colorArr.count)))
                cell.circleSix.backgroundColor = colorArr[randomIndex6]
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
