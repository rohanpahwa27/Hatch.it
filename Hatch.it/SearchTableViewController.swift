//
//  SearchTableViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 11/25/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
struct globalEvent{
    static var selectedRow = 0
    static var eventList = [Event]()
}
class SearchTableViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    var ref: DatabaseReference!
    var refHandle: UInt!
    var refresher: UIRefreshControl!
    var isSearching = false
    var filteredEventList = [Event]()
    var sortSpots:[(eventName: String, spots: Int)] = []
    var sortDate = [String]()
    var sortByHeads = false
    var sortbyDate = false
    var sortDistance = false
    var sortDistance2 = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        self.tableView.delegate = self
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull Down to Refresh")
        refresher.addTarget(self, action: #selector(fetchEvents), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        searchBar.returnKeyType = UIReturnKeyType.done
        ref = Database.database().reference()
        fetchEvents()
         NotificationCenter.default.addObserver(self, selector: #selector(sortByPublicEvents), name: NSNotification.Name(rawValue: "callForAlert"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sortByPrivateEvents), name: NSNotification.Name(rawValue: "callForAlert2"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchEvents), name: NSNotification.Name(rawValue: "callForAlert3"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sortBySpotsRemaining), name: NSNotification.Name(rawValue: "callForAlert4"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sortByDate), name: NSNotification.Name(rawValue: "callForAlert5"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sortByDistance), name: NSNotification.Name(rawValue: "callForAlert6"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sortByDistance2), name: NSNotification.Name(rawValue: "callForAlert7"), object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    func sortByDistance2() {
        globalEvent.eventList = []
        sortDistance2 = true
        sortDistance = false
        sortbyDate = false
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
                event.numOfHead = dict["Number of Heads"] as? String
                event.eventDescription = dict["Event Description"] as? String
                event.uuid = dict["Event UUID"] as? String
                let eventLong = dict["Longitude"] as? Double
                let eventLat = dict["Latitude"] as? Double
                let coordinate₀ = CLLocation(latitude: currentlat, longitude: currentlong)
                let coordinate₁ = CLLocation(latitude: eventLat!, longitude: eventLong!)
                let distanceInMeters = coordinate₀.distance(from: coordinate₁)
                let distanceInMiles = round(10.0 * distanceInMeters * 0.000621371)/10.0
                event.distance = distanceInMiles
                globalEvent.eventList.append(event)
                globalEvent.eventList.sort(by: {$0.distance > $1.distance})
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            }
            
        })
    }
    func sortByDistance() {
        globalEvent.eventList = []
        sortDistance = true
        sortbyDate = false
        sortDistance2 = false
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
                event.numOfHead = dict["Number of Heads"] as? String
                event.eventDescription = dict["Event Description"] as? String
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
    func sortByDate() {
        sortbyDate = true
        sortDistance = false
        sortByHeads = false
        sortDistance2 = false
        var convertedArray: [Date] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        for dat in sortDate {
            let date = dateFormatter.date(from: dat)
            if let date = date {
                convertedArray.append(date)
            }
        }
        
        var ready = convertedArray.sorted(by: { $0.compare($1) == .orderedDescending })
        
        globalEvent.eventList = []
        var i = 0
        refHandle = ref.child("Events").observe(.childAdded, with: {(snapshot) in
        if let dict = snapshot.value as! [String: AnyObject]?
        {
            
            let event = Event()
            event.eventName = dict["Event Name"] as? String
            event.uuid = dict["Event UUID"] as? String
            event.location = dict["Event Location"] as? String
            event.eventImage = dict["Event Image"] as? String
            event.eventVisibility = dict["Accessibility"] as? String
            event.numOfHead = dict["Number of Heads"] as? String
            event.eventDescription = dict["Event Description"] as? String
            event.eventDate = dateFormatter.string(from: ready[i])
            globalEvent.eventList.append(event)
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
            i += 1
        }
        
        
    })
    }
    func sortBySpotsRemaining() {
        sortByHeads = true
        sortbyDate = false
        sortDistance = false
        sortDistance2 = false
        globalEvent.eventList = []
        var i = 0
        sortSpots = sortSpots.sorted(by: {$0.spots > $1.spots})
        refHandle = ref.child("Events").observe(.childAdded, with: {(snapshot) in
            if let dict = snapshot.value as! [String: AnyObject]?
            {
                
                    let event = Event()
                    event.eventName = dict["Event Name"] as? String
                    event.location = dict["Event Location"] as? String
                    event.eventImage = dict["Event Image"] as? String
                event.eventVisibility = dict["Accessibility"] as? String
                event.uuid = dict["Event UUID"] as? String
                event.eventDescription = dict["Event Description"] as? String
                    event.numOfHead = "\(self.sortSpots[i].spots)"
                    globalEvent.eventList.append(event)
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                i += 1
            }
           
            
        })
    }
    func sortByPrivateEvents() {
        sortByHeads = false
        sortbyDate = false
        sortDistance = false
        sortDistance2 = false
        globalEvent.eventList = []
        refHandle = ref.child("Events").observe(.childAdded, with: {(snapshot) in
            if let dict = snapshot.value as! [String: AnyObject]?
            {
                if(dict["Accessibility"] as? String == "Private")
                {
                    let event = Event()
                    event.eventName = dict["Event Name"] as? String
                    event.location = dict["Event Location"] as? String
                    event.eventVisibility = dict["Accessibility"] as? String
                    event.uuid = dict["Event UUID"] as? String
                    event.numOfHead = dict["Number of Heads"] as? String
                    event.eventDescription = dict["Event Description"] as? String
                    event.eventImage = dict["Event Image"] as? String
                    globalEvent.eventList.append(event)
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                }
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            }
            
        })
    }
    func sortByPublicEvents() {
        sortByHeads = false
        sortbyDate = false
        sortDistance = false
        sortDistance2 = false
        globalEvent.eventList = []
        refHandle = ref.child("Events").observe(.childAdded, with: {(snapshot) in
            if let dict = snapshot.value as! [String: AnyObject]?
            {
                if(dict["Accessibility"] as? String == "Public")
                {
                    let event = Event()
                    event.eventName = dict["Event Name"] as? String
                    event.location = dict["Event Location"] as? String
                    event.numOfHead = dict["Number of Heads"] as? String
                    event.uuid = dict["Event UUID"] as? String
                    event.eventDescription = dict["Event Description"] as? String
                    event.eventVisibility = dict["Accessibility"] as? String
                    event.eventImage = dict["Event Image"] as? String
                    globalEvent.eventList.append(event)
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                }
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            }
            
        })
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text == nil || searchBar.text == "")
        {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        }
        else{
            isSearching = true
            filteredEventList = globalEvent.eventList.filter({$0.eventName?.lowercased().range(of: searchBar.text!.lowercased()) != nil})
            tableView.reloadData()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(isSearching)
        {
            return filteredEventList.count
        }
        return globalEvent.eventList.count
    }
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        performSegue(withIdentifier: "eventInfo", sender: self)
        globalEvent.selectedRow = indexPath.row
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellID") as? TableViewCell else {
            return UITableViewCell()
        }
        cell.eventImage.layer.cornerRadius = 10
        cell.eventImage.layer.masksToBounds = true
        let url = URL(string: globalEvent.eventList[indexPath.row].eventImage!)
        getDataFromUrl(url: url!) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                cell.eventImage.image = UIImage(data: data)
            }
        }
        if(isSearching)
        {
            cell.eventName.text = filteredEventList[indexPath.row].eventName
            cell.eventType.text = globalEvent.eventList[indexPath.row].location
            if(sortByHeads)
            {
                
                cell.filterCriteria.text = globalEvent.eventList[indexPath.row].numOfHead
            }
            else if(sortbyDate)
            {
                cell.filterCriteria.text = globalEvent.eventList[indexPath.row].eventDate
            }
            else if(sortDistance || sortDistance2)
            {
                cell.filterCriteria.text = "\(globalEvent.eventList[indexPath.row].distance) mi"
            }
            else
            {
                cell.filterCriteria.text = globalEvent.eventList[indexPath.row].eventVisibility
            }
        }
        else
        {
            cell.eventName.text = globalEvent.eventList[indexPath.row].eventName
            cell.eventType.text = globalEvent.eventList[indexPath.row].location
            if(sortByHeads)
            {
               
                cell.filterCriteria.text = globalEvent.eventList[indexPath.row].numOfHead
            }
            else if(sortbyDate)
            {
                cell.filterCriteria.text = globalEvent.eventList[indexPath.row].eventDate
            }
            else if(sortDistance || sortDistance2)
            {
                cell.filterCriteria.text = "\(globalEvent.eventList[indexPath.row].distance) mi"
            }
            else
            {
                cell.filterCriteria.text = globalEvent.eventList[indexPath.row].eventVisibility
            }
        }
        return cell
    }
    func fetchEvents() {
        sortByHeads = false
        sortbyDate = false
        sortDistance = false
        globalEvent.eventList = []
        refHandle = ref.child("Events").observe(.childAdded, with: {(snapshot) in
            if let dict = snapshot.value as! [String: AnyObject]?
            {
                let event = Event()
                event.eventName = dict["Event Name"] as? String
                event.location = dict["Event Location"] as? String
                event.eventVisibility = dict["Accessibility"] as? String
                event.numOfHead = dict["Number of Heads"] as? String
                event.eventDescription = dict["Event Description"] as? String
                event.eventDate = dict["Date"] as? String
                event.eventImage = dict["Event Image"] as? String
                event.uuid = dict["Event UUID"] as? String
                for events in snapshot.children.allObjects as! [DataSnapshot]
                {
                    if(events.key == "Interested Users")
                    {
                        for users in events.children.allObjects as! [DataSnapshot] {
                          event.interestedUsers.append(users.value as! String)
                        }
                    }
                    else if(events.key == "Users Going")
                    {
                        for users in events.children.allObjects as! [DataSnapshot] {
                            event.usersGoing.append(users.value as! String)
                        }
                    }
                }
                if let value = Int(event.numOfHead!){
                    self.sortSpots.append((eventName: event.eventName!, spots: value))
                }
                else{
                   self.sortSpots.append((eventName: event.eventName!, spots: 10))
                }
                self.sortDate.append(event.eventDate!)
                globalEvent.eventList.append(event)
                self.tableView.reloadData()

            }
            
        })
        refresher.endRefreshing()
    }
}
