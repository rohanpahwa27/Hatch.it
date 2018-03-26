//
//  NotificationTableViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 12/23/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
import PusherSwift
import Alamofire
import FirebaseDatabase
class NotificationTableViewController: UITableViewController, CAAnimationDelegate{
    let refresher = UIRefreshControl()
    let loader = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    override func viewDidLoad() {
        refresher.attributedTitle = NSAttributedString(string: "Pull Down to Refresh")
        refresher.addTarget(self, action: #selector(reloadView), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        loader.hidesWhenStopped = true
        loader.center = tableView.center
        tableView.addSubview(loader)
        super.viewDidLoad()
        loader.startAnimating()
        tableView.tableFooterView = UIView()
        globalVariables.notification = []
        tableView.delegate = self
        tableView.dataSource = self
    }
    @IBAction func pressed(_ sender: UIButton) {
        let requestString = URL(string: "https://b141bfbf-5b9b-473a-bb22-b7000af9a6e5.pushnotifications.pusher.com/publish_api/v1/instances/b141bfbf-5b9b-473a-bb22-b7000af9a6e5/publishes")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer 69B896769CD54C62539CB43C9E6F869",
            "Content-Type": "application/json"
        ]
        //let params = ["interests": ["hello"],
            //["apns":
                //["alert":
                   // ["title": "hello", "body": "hello, mate"]
               // ]
            //]
        //]
        //Alamofire.request(requestString!, method: .post, parameters: params, headers: headers).responseJSON { response in
           // print(response)
           // print(response.response)
        //}
    }
    func reloadView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        refresher.endRefreshing()
    }
    override func viewDidAppear(_ animated: Bool) {
        globalVariables.notification = []
        Database.database().reference().child("Notifications").observe(.childAdded, with: { (snapshot) in
            for notifID in snapshot.children.allObjects as! [DataSnapshot]
            {
                if(snapshot.key == Auth.auth().currentUser?.uid){
                let notification = Notifiction()
                for child in notifID.children.allObjects as! [DataSnapshot]
                {
                    if(child.key == "Notification Title"){
                        notification.title = child.value as! String
                    }
                    else if(child.key == "Notification Body"){
                        notification.body = child.value as! String
                    }
                    else if(child.key == "Notification UID"){
                        notification.uid = child.value as! String
                    }
                    else if(child.key == "Notification Time"){
                        notification.time = child.value as! String
                    }
                    else if(child.key == "Notification Image"){
                        notification.image = child.value as! String
                    }
                }
                globalVariables.notification.append(notification)
                globalVariables.notification.sort(by: { $0.time.compare($1.time) == .orderedDescending })
                self.loader.stopAnimating()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
            }
            }
        })
        if(globalVariables.notification.count == 0){
            loader.stopAnimating()
        }
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
        return globalVariables.notification.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNum") as! NotificationTableViewCell
            cell.notificationTitle.alpha = 0
            cell.notificationImage.alpha = 0
            cell.notificationBody.alpha = 0
            cell.requestedTitle.alpha = 1
            cell.notificationTime.alpha = 0
            cell.statement.alpha = 1
            cell.accessoryType = .disclosureIndicator
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        }
        else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellNum") as? NotificationTableViewCell else {
                return UITableViewCell()
            }
            cell.notificationTitle.alpha = 1
            cell.notificationImage.alpha = 1
            cell.notificationBody.alpha = 1
            cell.requestedTitle.alpha = 0
            cell.notificationTime.alpha = 1
            cell.statement.alpha = 0
        cell.notificationTitle.text = globalVariables.notification[indexPath.row - 1].title
        cell.notificationBody.text = globalVariables.notification[indexPath.row - 1].body
            if(cell.notificationTitle.text == "Congratulations!"){
                let url = URL(string: globalVariables.notification[indexPath.row - 1].image)
                URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                    if(error == nil)
                    {
                        DispatchQueue.main.async {
                            cell.notificationImage.image = UIImage(data: data!)
                        }
                    }
                    
                }).resume()
            }
            else{
                cell.notificationImage.image = #imageLiteral(resourceName: "DefaultImage")
            }
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.year,.month,.weekOfMonth,.day,.hour,.minute,.second]
        dateComponentsFormatter.maximumUnitCount = 1
        dateComponentsFormatter.unitsStyle = .full
        dateComponentsFormatter.string(from: Date(), to: Date(timeIntervalSinceNow: 4000000))
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let date1 = dateFormatter.date(from: globalVariables.notification[indexPath.row - 1].time)
        let date2 = Date()
        let timeOffset = date2.offset(from: date1!)
        cell.notificationTime.text = timeOffset
        return cell
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row != 0){
            return 75
        }
        return 60
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            performSegue(withIdentifier: "requested", sender: self)
        }
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
       2 return true
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


