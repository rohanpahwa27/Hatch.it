//
//  RequestedUsersTableViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 1/12/18.
//  Copyright © 2018 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
struct requestedUsers{
    static var users:[(name: String, event: String)] = []
}
class RequestedUsersTableViewController: UITableViewController {
    var host = true
    func approvedClicked(_ sender: UIButton){
        sender.alpha = 0
        let index = IndexPath(row: sender.tag, section: 0)
        let cell = tableView.cellForRow(at: index) as! ReqestTableViewCell
        cell.denyButton.alpha = 0
        cell.decision.text = "Approved"
        Database.database().reference().child("Events").observe(.childAdded, with: { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                if(child.key == "Requested Users"){
                    for users in child.children.allObjects as! [DataSnapshot]{
                        if(users.value as? String == requestedUsers.users[sender.tag].name){
                            Database.database().reference().child("Events").child(snapshot.key).child("Requested Users").child(users.key).removeValue()
                            Database.database().reference().child("Events").child(snapshot.key).child("Users Going").childByAutoId().setValue(users.value as? String)
                        }
                    }
                }
            }
        })
    }
    func denyClicked(_ sender: UIButton) {
        sender.alpha = 0
        let index = IndexPath(row: sender.tag, section: 0)
        let cell = tableView.cellForRow(at: index) as! ReqestTableViewCell
        cell.approveButton.alpha = 0
        cell.decision.text = "Denied"
        Database.database().reference().child("Events").observe(.childAdded, with: { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                if(child.key == "Requested Users"){
                    for users in child.children.allObjects as! [DataSnapshot]{
                        if(users.value as? String == requestedUsers.users[sender.tag].name){
                            Database.database().reference().child("Events").child(snapshot.key).child("Requested Users").child(users.key).removeValue()
                        }
                    }
                }
            }
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        requestedUsers.users = []
        Database.database().reference().child("Events").observe(.childAdded, with: { (snapshot) in
            var eventName = ""
            self.host = false
            for eventInfo in snapshot.children.allObjects as! [DataSnapshot]{
                if(eventInfo.key == "Event Name"){
                    eventName = eventInfo.value as! String
                }
                if(eventInfo.key == "Host"){
                    if(eventInfo.value as? String == Auth.auth().currentUser?.uid){
                        self.host = true
                    }
                }
                if(eventInfo.key == "Requested Users"){
                    for users in eventInfo.children.allObjects as! [DataSnapshot]{
                        if(self.host){
                            requestedUsers.users.append((name: users.value as! String, event: eventName))
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
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
           return requestedUsers.users.count
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var firstName = ""
        var lastName = ""
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "user") as? ReqestTableViewCell else {
            return UITableViewCell()
        }
        Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
            
            for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                if(eventID.key == requestedUsers.users[indexPath.row].name)
                {
                    for child in eventID.children.allObjects as! [DataSnapshot] {
                        if(child.key == "First Name")
                        {
                            firstName = child.value as! String
                        }
                        if(child.key == "Last Name"){
                            lastName = child.value as! String
                        }
                        if(child.key == "Profile Picture"){
                            print(child.value as! String)
                            if(child.value as! String == "default.png"){
                                cell.profilePicture.image = #imageLiteral(resourceName: "DefaultImage")
                            }
                            else{
                                let url = URL(string: child.value as! String)
                                URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                                    if(error == nil)
                                    {
                                        DispatchQueue.main.async {
                                            cell.profilePicture.image = UIImage(data: data!)
                                            //cell.loader.stopAnimating()
                                        }
                                    }
                                    
                                }).resume()
                            }
                        }
                    }
                    cell.eventName.text = requestedUsers.users[indexPath.row].event
                    cell.fullName.text = "\(firstName) \(lastName)"
                    cell.denyButton.tag = indexPath.row
                    cell.approveButton.tag = indexPath.row
                    cell.selectionStyle = .none
                    cell.denyButton.addTarget(self, action: #selector(self.denyClicked), for: .touchUpInside)
                    cell.approveButton.addTarget(self, action: #selector(self.approvedClicked), for: .touchUpInside)
                    
                }
                
            }
        })
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
