//
//  NotificationControlTableViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 12/23/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
class NotificationControlTableViewController: UITableViewController {
    let uid = Auth.auth().currentUser?.uid
    @IBOutlet weak var enableNotif: UISwitch!
    @IBOutlet weak var interestedToggle: UISwitch!
    @IBOutlet weak var attendingToggle: UISwitch!
    @IBAction func enableNotifications(_ sender: UISwitch) {
           UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, completionHandler: nil)
    }
    @IBAction func attendingToggled(_ sender: UISwitch) {
        
       if(sender.isOn)
       {
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications {Database.database().reference().child("Users").child(uid!).child("isAttendingNotification").setValue("true")
            Messaging.messaging().subscribe(toTopic: "attendingEvents")
        } else {
            self.attendingToggle.setOn(false, animated: true)
        }
        
       }
       else{
        Database.database().reference().child("Users").child(uid!).child("isAttendingNotification").setValue("false")
        Messaging.messaging().unsubscribe(fromTopic: "attendingEvents")
        }
    }
    @IBAction func interestedToggled(_ sender: UISwitch) {
        let uid = Auth.auth().currentUser?.uid
        if(sender.isOn)
        {
            let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
            if isRegisteredForRemoteNotifications { Database.database().reference().child("Users").child(uid!).child("isInterestedNotification").setValue("true")
                Messaging.messaging().subscribe(toTopic: "interestedEvents")
                
            }
            else {
                interestedToggle.setOn(false, animated: true)
        }
        }
        else{
                Database.database().reference().child("Users").child(uid!).child("isInterestedNotification").setValue("false")
            Messaging.messaging().unsubscribe(fromTopic: "interestedEvents")
        }
    }
    func didBecomeActive() {
         let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications {
            enableNotif.setOn(true, animated: true)
            Database.database().reference().child("Users").child(uid!).child("isAttendingNotification").setValue("true")
            Database.database().reference().child("Users").child(uid!).child("isInterestedNotification").setValue("true")
        } else {
            enableNotif.setOn(false, animated: true)
            interestedToggle.setOn(false, animated: true)
            attendingToggle.setOn(false, animated: true)
            Database.database().reference().child("Users").child(uid!).child("isInterestedNotification").setValue("false")
            Database.database().reference().child("Users").child(uid!).child("isAttendingNotification").setValue("false")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
         NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
