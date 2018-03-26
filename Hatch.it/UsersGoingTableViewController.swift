//
//  UsersGoingTableViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 1/10/18.
//  Copyright © 2018 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
struct user{
    static var userID = ""
}
class UsersGoingTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var currentUserLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func segmentedControlSwitched(_ sender: UISegmentedControl) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
        }
    }
    var arr = [String]()
    var arr2 = [String]()
    override func viewWillAppear(_ animated: Bool) {
        print("Check \(variables.check)")
        print("Attended \(variables.attended)")
    }
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        super.viewDidLoad()
        segmentedControl.layer.cornerRadius = 10
        segmentedControl.clipsToBounds = true
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(variables.link){
            print("tes")
            if(segmentedControl.selectedSegmentIndex == 0){
                if(variables.event[0].usersGoing.count == 0){
                    currentUserLabel.alpha = 1
                }
                else{
                    currentUserLabel.alpha = 0
                }
                return variables.event[0].usersGoing.count
            }
            else{
                if(variables.event[0].interestedUsers.count == 0){
                    currentUserLabel.alpha = 1
                }
                else{
                    currentUserLabel.alpha = 0
                }
                return variables.event[0].interestedUsers.count
            }
        }
        else if(variables.check){
            print("YES")
            if(segmentedControl.selectedSegmentIndex == 0){
                if(global.eventsHosted[globalEvent.selectedRow].usersGoing.count == 0){
                    currentUserLabel.alpha = 1
                }
                else{
                    currentUserLabel.alpha = 0
                }
                return global.eventsHosted[globalEvent.selectedRow].usersGoing.count
            }
            else{
                if(global.eventsHosted[globalEvent.selectedRow].interestedUsers.count == 0){
                    currentUserLabel.alpha = 1
                }
                else{
                    currentUserLabel.alpha = 0
                }
                return global.eventsHosted[globalEvent.selectedRow].interestedUsers.count
            }
        }
        else if(variables.attended){
            print("no")
            if(segmentedControl.selectedSegmentIndex == 0){
                if(global.yourEvents[globalEvent.selectedRow].usersGoing.count == 0){
                    currentUserLabel.alpha = 1
                }
                else{
                    currentUserLabel.alpha = 0
                }
                return global.yourEvents[globalEvent.selectedRow].usersGoing.count
            }
            else{
                if(global.yourEvents[globalEvent.selectedRow].interestedUsers.count == 0){
                    currentUserLabel.alpha = 1
                }
                else{
                    currentUserLabel.alpha = 0
                }
                return global.yourEvents[globalEvent.selectedRow].interestedUsers.count
            }
        }
        else{
        if(globalEvent.searching){
            if(globalEvent.filteredEventList[globalEvent.selectedRow].interestedUsers.count == 0){
                currentUserLabel.alpha = 1
            }
            if(segmentedControl.selectedSegmentIndex == 0){
                if(globalEvent.filteredEventList[globalEvent.selectedRow].usersGoing.count == 0){
                    currentUserLabel.alpha = 1
                }
                else{
                    currentUserLabel.alpha = 0
                }
                return globalEvent.filteredEventList[globalEvent.selectedRow].usersGoing.count
            }
            else{
                if(globalEvent.filteredEventList[globalEvent.selectedRow].interestedUsers.count == 0){
                    currentUserLabel.alpha = 1
                }
                else{
                    currentUserLabel.alpha = 0
                }
                return globalEvent.filteredEventList[globalEvent.selectedRow].interestedUsers.count
            }
        }
        else{
            if(segmentedControl.selectedSegmentIndex == 0){
                if(globalEvent.eventList[globalEvent.selectedRow].usersGoing.count == 0){
                    currentUserLabel.alpha = 1
                }
                else{
                    currentUserLabel.alpha = 0
                }
                return globalEvent.eventList[globalEvent.selectedRow].usersGoing.count
            }
            else{
                if(globalEvent.eventList[globalEvent.selectedRow].interestedUsers.count == 0){
                    currentUserLabel.alpha = 1
                }
                else{
                    currentUserLabel.alpha = 0
                }
                return globalEvent.eventList[globalEvent.selectedRow].interestedUsers.count
            }
        }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(variables.link){
            if(segmentedControl.selectedSegmentIndex == 0){
                var firstName = ""
                var lastName = ""
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "usersGoing") as? UsersTableViewCell else {
                    return UITableViewCell()
                }
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == variables.event[0].usersGoing[indexPath.row])
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
                                                    cell.loader.stopAnimating()
                                                }
                                            }
                                            
                                        }).resume()
                                    }
                                }
                            }
                            self.arr.append("\(firstName) \(lastName)")
                        }
                        
                    }
                    cell.fullName.text = self.arr[indexPath.row]
                })
                
                return cell
            }
            else{
                var firstName = ""
                var lastName = ""
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "usersGoing") as? UsersTableViewCell else {
                    return UITableViewCell()
                }
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == variables.event[0].interestedUsers[indexPath.row])
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
                                                    cell.loader.stopAnimating()
                                                }
                                            }
                                            
                                        }).resume()
                                    }
                                }
                            }
                            self.arr2.append("\(firstName) \(lastName)")
                            
                        }
                        
                    }
                    cell.fullName.text = self.arr2[indexPath.row]
                })
                
                return cell
            }
        }
        
        else if(variables.check){
            if(segmentedControl.selectedSegmentIndex == 0){
                var firstName = ""
                var lastName = ""
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "usersGoing") as? UsersTableViewCell else {
                    return UITableViewCell()
                }
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == global.eventsHosted[globalEvent.selectedRow].usersGoing[indexPath.row])
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
                                                    cell.loader.stopAnimating()
                                                }
                                            }
                                            
                                        }).resume()
                                    }
                                }
                            }
                            self.arr.append("\(firstName) \(lastName)")
                        }
                        
                    }
                    cell.fullName.text = self.arr[indexPath.row]
                })
                
                return cell
            }
            else{
                var firstName = ""
                var lastName = ""
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "usersGoing") as? UsersTableViewCell else {
                    return UITableViewCell()
                }
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == global.eventsHosted[globalEvent.selectedRow].interestedUsers[indexPath.row])
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
                                                    cell.loader.stopAnimating()
                                                }
                                            }
                                            
                                        }).resume()
                                    }
                                }
                            }
                            self.arr2.append("\(firstName) \(lastName)")
                            
                        }
                        
                    }
                    cell.fullName.text = self.arr2[indexPath.row]
                })
                
                return cell
            }
        }
        else if(variables.attended){
            if(segmentedControl.selectedSegmentIndex == 0){
                var firstName = ""
                var lastName = ""
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "usersGoing") as? UsersTableViewCell else {
                    return UITableViewCell()
                }
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == global.yourEvents[globalEvent.selectedRow].usersGoing[indexPath.row])
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
                                                    cell.loader.stopAnimating()
                                                }
                                            }
                                            
                                        }).resume()
                                    }
                                }
                            }
                            self.arr.append("\(firstName) \(lastName)")
                        }
                        
                    }
                    cell.fullName.text = self.arr[indexPath.row]
                })
                
                return cell
            }
            else{
                var firstName = ""
                var lastName = ""
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "usersGoing") as? UsersTableViewCell else {
                    return UITableViewCell()
                }
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == global.yourEvents[globalEvent.selectedRow].interestedUsers[indexPath.row])
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
                                                    cell.loader.stopAnimating()
                                                }
                                            }
                                            
                                        }).resume()
                                    }
                                }
                            }
                            self.arr2.append("\(firstName) \(lastName)")
                            
                        }
                        
                    }
                    cell.fullName.text = self.arr2[indexPath.row]
                })
                
                return cell
            }
        }
        else{
        if(globalEvent.searching){
            if(segmentedControl.selectedSegmentIndex == 0){
                var firstName = ""
                var lastName = ""
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "usersGoing") as? UsersTableViewCell else {
                    return UITableViewCell()
                }
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[globalEvent.selectedRow].usersGoing[indexPath.row])
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
                                                cell.loader.stopAnimating()
                                            }
                                        }
                                        
                                    }).resume()
                                    }
                                }
                            }
                            self.arr.append("\(firstName) \(lastName)")
                        }
                        
                    }
                    cell.fullName.text = self.arr[indexPath.row]
                })
                
                return cell
            }
            else{
                var firstName = ""
                var lastName = ""
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "usersGoing") as? UsersTableViewCell else {
                    return UITableViewCell()
                }
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.filteredEventList[globalEvent.selectedRow].interestedUsers[indexPath.row])
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
                                                cell.loader.stopAnimating()
                                            }
                                        }
                                        
                                    }).resume()
                                    }
                                }
                            }
                            self.arr2.append("\(firstName) \(lastName)")
                            
                        }
                        
                    }
                    cell.fullName.text = self.arr2[indexPath.row]
                })
                
                return cell
            }
        }
        else{
            var firstName = ""
            var lastName = ""
            if(segmentedControl.selectedSegmentIndex == 0){
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "usersGoing") as? UsersTableViewCell else {
                    return UITableViewCell()
                }
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[globalEvent.selectedRow].usersGoing[indexPath.row])
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
                                                cell.loader.stopAnimating()
                                            }
                                        }
                                        
                                    }).resume()
                                    }
                                }
                            }
                            self.arr.append("\(firstName) \(lastName)")
                            
                        }
                        
                    }
                    cell.fullName.text = self.arr[indexPath.row]
                })
                
                return cell
            }
            else{
                var firstName = ""
                var lastName = ""
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "usersGoing") as? UsersTableViewCell else {
                    return UITableViewCell()
                }
                Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { snapshot in
                    
                    for eventID in snapshot.children.allObjects as! [DataSnapshot] {
                        if(eventID.key == globalEvent.eventList[globalEvent.selectedRow].interestedUsers[indexPath.row])
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
                                                cell.loader.stopAnimating()
                                            }
                                        }
                                        
                                    }).resume()
                                    }
                                }
                            }
                            self.arr2.append("\(firstName) \(lastName)")
                        }
                        
                    }
                    cell.fullName.text = self.arr2[indexPath.row]
                })
                
                return cell
            }
        }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(variables.link){
            if(segmentedControl.selectedSegmentIndex == 0){
                user.userID = variables.event[0].usersGoing[indexPath.row]
            }
            else{
                user.userID = variables.event[0].interestedUsers[indexPath.row]
            }
        }
        else if(variables.check){
                if(segmentedControl.selectedSegmentIndex == 0){
                    print(global.eventsHosted)
                    print(globalEvent.selectedRow)
                    print(global.eventsHosted[globalEvent.selectedRow].interestedUsers)
                    user.userID = global.eventsHosted[globalEvent.selectedRow].usersGoing[indexPath.row]
                }
                else{
                    print(global.eventsHosted)
                    print(globalEvent.selectedRow)
                    print(global.eventsHosted[globalEvent.selectedRow].interestedUsers)
                    user.userID = global.eventsHosted[globalEvent.selectedRow].interestedUsers[indexPath.row]
                }
        }
        else if(variables.attended){
            if(segmentedControl.selectedSegmentIndex == 0){
                user.userID = global.yourEvents[globalEvent.selectedRow].usersGoing[indexPath.row]
            }
            else{
                user.userID = global.yourEvents[globalEvent.selectedRow].interestedUsers[indexPath.row]
            }
        }
        else{
            if(globalEvent.searching){
                if(segmentedControl.selectedSegmentIndex == 0){
                    user.userID = globalEvent.filteredEventList[globalEvent.selectedRow].usersGoing[indexPath.row]
                }
                else{
                    user.userID = globalEvent.filteredEventList[globalEvent.selectedRow].interestedUsers[indexPath.row]
                }
            }
            else{
                if(segmentedControl.selectedSegmentIndex == 0){
                    user.userID = globalEvent.eventList[globalEvent.selectedRow].usersGoing[indexPath.row]
                }
                else{
                    user.userID = globalEvent.eventList[globalEvent.selectedRow].interestedUsers[indexPath.row]
                }
            }
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}
