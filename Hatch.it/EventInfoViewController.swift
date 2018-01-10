//
//  EventInfoViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 11/28/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
import Mapbox
import CoreLocation
struct user {
    static var userID = ""
}
class EventInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MGLMapViewDelegate {
     var arr = [String]()
    var arr3 = ["Find Out Who's Going", "Find Out Who's Interested"]
    var mapView = MGLMapView()
    var arr2 = [String]()
    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var tableView3: UITableView!
    @IBOutlet weak var hostMapView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var eventAddress: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var numberOfSpots: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBAction func interestedPressed(_ sender: UIButton) {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let genNum = NSUUID().uuidString
        let uuid = globalEvent.eventList[globalEvent.selectedRow].uuid
        ref.child("Events").child(uuid!).child("Interested Users").updateChildValues([genNum: uid!])
    }
    @IBAction func goingPressed(_ sender: UIButton) {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let genNum = NSUUID().uuidString
        let uuid = globalEvent.eventList[globalEvent.selectedRow].uuid
        ref.child("Events").child(uuid!).child("Users Going").updateChildValues([genNum: uid!])
    }
    @IBAction func sharePressed(_ sender: UIButton) {
    }
    override func viewDidLayoutSubviews() {
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 300)
    }
    override func viewDidLoad() {
        tableView3.tableFooterView = UIView()
        let locManager = CLLocationManager()
        let urlString = URL(string: "mapbox://styles/stephenth0ma5/cjayeqlub44lh2qqyzmmpynhc")
        let lat = locManager.location?.coordinate.latitude
        let long = locManager.location?.coordinate.longitude
        mapView = MGLMapView(frame: hostMapView.bounds, styleURL: urlString)
        mapView.delegate = self
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.showsUserLocation = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: lat!, longitude: long!), zoomLevel: 9, animated: false)
        hostMapView.addSubview(mapView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView2.delegate = self
        tableView2.dataSource = self
        tableView3.delegate = self
        tableView3.dataSource = self
        tableView.reloadData()
        super.viewDidLoad()
        let startTime = globalEvent.eventList[globalEvent.selectedRow].startTime
        let endTime = globalEvent.eventList[globalEvent.selectedRow].endTime
        eventTime.text = "\(startTime!) - \(endTime!)"
        eventAddress.text = globalEvent.eventList[globalEvent.selectedRow].eventAddress
        eventDate.text = globalEvent.eventList[globalEvent.selectedRow].eventDate
        eventName.text =  globalEvent.eventList[globalEvent.selectedRow].eventName
        eventLocation.text = globalEvent.eventList[globalEvent.selectedRow].location
        eventDescription.text = globalEvent.eventList[globalEvent.selectedRow].eventDescription
        numberOfSpots.text = globalEvent.eventList[globalEvent.selectedRow].numOfHead
        let url = URL(string: globalEvent.eventList[globalEvent.selectedRow].eventImage!)
        URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
            if(error == nil)
            {
                DispatchQueue.main.async {
                    self.eventImage.image = UIImage(data: data!)
                }
            }
        }).resume()
        
            
        
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == self.tableView)
        {
         user.userID = globalEvent.eventList[globalEvent.selectedRow].interestedUsers[indexPath.row]
        }
        else if(tableView == self.tableView2)
        {
            user.userID = globalEvent.eventList[globalEvent.selectedRow].usersGoing[indexPath.row]
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableView == self.tableView)
        {
            return globalEvent.eventList[globalEvent.selectedRow].interestedUsers.count
        }
        else if(tableView == self.tableView2)
        {
            return globalEvent.eventList[globalEvent.selectedRow].usersGoing.count
        }
        else if(tableView == self.tableView3)
        {
            return 2
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == self.tableView)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                
                for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                    if(eventID.key == globalEvent.eventList[globalEvent.selectedRow].interestedUsers[indexPath.row])
                    {
                        for child in eventID.children.allObjects as! [DataSnapshot] {
                            if(child.key == "First Name")
                            {
                                self.arr2.append(child.value as! String)
                            }
                        }
                        
                    }
                    
                }
                cell.textLabel?.text = self.arr2[indexPath.row]
            })
            
            return cell
        }
        else if(tableView == self.tableView2)
        {
           
           let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell2", for: indexPath)
            Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                
               for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                 if(eventID.key == globalEvent.eventList[globalEvent.selectedRow].usersGoing[indexPath.row])
                 {
                    for child in eventID.children.allObjects as! [DataSnapshot] {
                        if(child.key == "First Name")
                        {
                            self.arr.append(child.value as! String)
                        }
                    }
                
                }
                
                }
                  cell.textLabel?.text = self.arr[indexPath.row]
            })
         
           return cell
        }
        else if(tableView == self.tableView3)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell3", for: indexPath)
            cell.textLabel?.text = self.arr3[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
