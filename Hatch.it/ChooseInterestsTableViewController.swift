//
//  ChooseInterestsTableViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 2/4/18.
//  Copyright © 2018 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
import AudioToolbox
class ChooseInterestsTableViewController: UITableViewController {
    var interestsArr = [String]()
    var checked = [Bool]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        navigationController?.navigationBar.barTintColor = UIColor(red: 101/255, green: 98/255, blue: 190/255, alpha: 1)
        self.navigationItem.setHidesBackButton(true, animated: true)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        Database.database().reference().child("Interests").observe(.childAdded, with: { (snapshot) in
            self.interestsArr.append(snapshot.value as! String)
            self.checked.append(false)
            self.tableView.reloadData()
        })
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return interestsArr.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! InterestsTableViewCell
        cell.interest.text = interestsArr[indexPath.row]
        if(checked[indexPath.row] == false){
            cell.accessoryType = .none
        }
        else{
            cell.accessoryType = .checkmark
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AudioServicesPlaySystemSound(1519)
        if let cell = tableView.cellForRow(at: indexPath) {
            if(checked[indexPath.row] == false){
                cell.accessoryType = .checkmark
                Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Interests").childByAutoId().setValue(interestsArr[indexPath.row])
                tableView.deselectRow(at: indexPath, animated: true)
                checked[indexPath.row] = true
            }
            else{
                cell.accessoryType = .none
                Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Interests").observe(.childAdded, with: { (snapshot) in
                    if(snapshot.value as? String == self.interestsArr[indexPath.row]){
                        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Interests").child(snapshot.key).removeValue()
                        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Interests").removeAllObservers()
                    }
                })
                tableView.deselectRow(at: indexPath, animated: true)
                checked[indexPath.row] = false
            }
        }
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
