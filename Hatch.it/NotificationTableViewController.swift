//
//  NotificationTableViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 12/23/17.
//  Copyright © 2017 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
class NotificationTableViewController: UITableViewController, CAAnimationDelegate{
    let gradient = CAGradientLayer()
    let refresher = UIRefreshControl()
    let loader = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    
    let gradientOne = UIColor(red: 139/255, green: 34/255, blue: 34/255, alpha: 1).cgColor
    let gradientThree = UIColor(red: 225/255, green: 201/255, blue: 222/255, alpha: 1).cgColor
    let gradientTwo = UIColor(red: 239/255, green: 59/255, blue: 51/255, alpha: 1).cgColor
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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    func reloadView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        refresher.endRefreshing()
    }
   
    func animateGradient() {
        if currentGradient < gradientSet.count - 1 {
            currentGradient += 1
        } else {
            currentGradient = 0
        }
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.repeatCount = Float.infinity
        gradientChangeAnimation.autoreverses = true
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradientChangeAnimation.duration = 3.0
        gradientChangeAnimation.toValue = gradientSet[currentGradient]
        gradientChangeAnimation.fillMode = kCAFillModeForwards
        //gradientChangeAnimation.isRemovedOnCompletion = false
        gradient.add(gradientChangeAnimation, forKey: "colorChange")
    
    }
    override func viewDidAppear(_ animated: Bool) {
        globalVariables.notification = []
        Database.database().reference().child("Notifications").observe(.childAdded, with: { (snapshot) in
            for notifID in snapshot.children.allObjects as! [DataSnapshot]
            {
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
                }
                globalVariables.notification.append(notification)
                self.loader.stopAnimating()
                self.tableView.reloadData()
            }
        })
        if(globalVariables.notification.count == 0){
            loader.stopAnimating()
        }
        gradientSet.append([gradientOne, gradientTwo])
        gradientSet.append([gradientTwo, gradientThree])
        gradientSet.append([gradientThree, gradientOne])
        //gradient.frame = cell.borderView.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        gradient.drawsAsynchronously = true
        animateGradient()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let uid = Auth.auth().currentUser?.uid
            let notificationUID = globalVariables.notification[indexPath.row].uid
            Database.database().reference().child("Notifications").child(uid!).child(notificationUID).removeValue()
            globalVariables.notification.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return globalVariables.notification.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellNum") as? NotificationTableViewCell else {
            return UITableViewCell()
        }
        cell.notificationTitle.text = globalVariables.notification[indexPath.row].title
        cell.notificationBody.text = globalVariables.notification[indexPath.row].body
        gradientSet.append([gradientOne, gradientTwo])
        gradientSet.append([gradientTwo, gradientThree])
        gradientSet.append([gradientThree, gradientOne])
        gradient.frame = cell.borderView.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.startPoint = CGPoint(x:0, y:0)
        gradient.endPoint = CGPoint(x:1, y:1)
        gradient.drawsAsynchronously = true
        cell.borderView.layer.addSublayer(gradient)
        animateGradient()
        return cell
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


