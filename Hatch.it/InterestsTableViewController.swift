//
//  InterestsTableViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 2/4/18.
//  Copyright © 2018 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
import AudioToolbox
class InterestsTableViewController: UITableViewController {
    var interestsArr = [String]()
    var checked = [Bool]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        interestsArr = []
        Database.database().reference().child("Interests").observe(.childAdded, with: { (snapshot) in
            self.interestsArr.append(snapshot.value as! String)
            self.checked.append(false)
            self.tableView.reloadData()
        })
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
        return interestsArr.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! InterestsTableViewCell
        cell.interest.text = interestsArr[indexPath.row]
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Interests").observe(.childAdded, with: { (snapshot) in
            if(snapshot.value as! String == self.interestsArr[indexPath.row]){
                self.checked[indexPath.row] = true
                cell.accessoryType = .checkmark
            }
        })
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
}
