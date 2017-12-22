//
//  EventInfoViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 11/28/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
struct user {
    static var userID = ""
}
class EventInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
     var arr = [String]()
    var arr2 = [String]()
    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var numberOfSpots: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventVisibility: UILabel!
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
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView2.delegate = self
        tableView2.dataSource = self
        tableView.reloadData()
        super.viewDidLoad()
        eventName.text = globalEvent.eventList[globalEvent.selectedRow].eventName
        eventLocation.text = globalEvent.eventList[globalEvent.selectedRow].location
        eventDescription.text = globalEvent.eventList[globalEvent.selectedRow].eventDescription
        eventVisibility.text = globalEvent.eventList[globalEvent.selectedRow].eventVisibility
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
