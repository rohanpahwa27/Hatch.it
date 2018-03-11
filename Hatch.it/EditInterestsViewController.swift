//
//  InterestsViewController.swift
//  Hatch.it
//
//  Created by Stephen Thomas on 1/27/18.
//  Copyright © 2018 Hatch Inc. All rights reserved.
//

import UIKit
import Firebase
import AudioToolbox
class EditInterestsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    let ref = Database.database().reference()
    var clickedArr = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    let selImageArr = [#imageLiteral(resourceName: "BasketballIcon"), #imageLiteral(resourceName: "BBQIcon"), #imageLiteral(resourceName: "DogIcon"), #imageLiteral(resourceName: "BadmintonIcon"), #imageLiteral(resourceName: "GolfIcon"), #imageLiteral(resourceName: "BookIcon"), #imageLiteral(resourceName: "HikingIcon"), #imageLiteral(resourceName: "PicnicIcon"), #imageLiteral(resourceName: "VolleyballIcon"), #imageLiteral(resourceName: "SoccerIcon"), #imageLiteral(resourceName: "SwimmingIcon"), #imageLiteral(resourceName: "WalkingIcon"), #imageLiteral(resourceName: "TennisIcon"), #imageLiteral(resourceName: "BaseballIcon"), #imageLiteral(resourceName: "FootballIcon"), #imageLiteral(resourceName: "BeachIcon"), #imageLiteral(resourceName: "WorkoutIcon"), #imageLiteral(resourceName: "CricketIcon"), #imageLiteral(resourceName: "BikingIcon"), #imageLiteral(resourceName: "ConcertIcon"), #imageLiteral(resourceName: "ClickedShoppingIcon"), #imageLiteral(resourceName: "ClickedEatingIcon"), #imageLiteral(resourceName: "ClickedDrinkingIcon"), #imageLiteral(resourceName: "ClickedReligonIcon"), #imageLiteral(resourceName: "ClickedVideoIcon"), #imageLiteral(resourceName: "ClickedMusicIcon"), #imageLiteral(resourceName: "ClickedDancingIcon"), #imageLiteral(resourceName: "ClickedTechIcon"), #imageLiteral(resourceName: "ClickedEducationIcon"), #imageLiteral(resourceName: "ClickedFinanceIcon"), #imageLiteral(resourceName: "ClickedCarsIcon"), #imageLiteral(resourceName: "ClickedPhotoIcon")]
    let imageArr = [#imageLiteral(resourceName: "ClickedBBIcon"), #imageLiteral(resourceName: "ClickedBBQIcon"), #imageLiteral(resourceName: "ClickedDogIcon"), #imageLiteral(resourceName: "ClickedBadmintonIcon"), #imageLiteral(resourceName: "ClickedGolfIcon"), #imageLiteral(resourceName: "ClickedBookIcon"), #imageLiteral(resourceName: "ClickedHikingIcon"), #imageLiteral(resourceName: "ClickedPicnicIcon"), #imageLiteral(resourceName: "ClickedVBIcon"), #imageLiteral(resourceName: "ClickedSoccerIcon"), #imageLiteral(resourceName: "ClickedSwimmingIcon"), #imageLiteral(resourceName: "ClickedWalkingIcon"), #imageLiteral(resourceName: "ClickedTennisIcon"), #imageLiteral(resourceName: "ClickedBaseballIcon"), #imageLiteral(resourceName: "ClickedFootballIcon"), #imageLiteral(resourceName: "ClickedBeachIcon"), #imageLiteral(resourceName: "ClickedWorkoutIcon"), #imageLiteral(resourceName: "ClickedCricketIcon"), #imageLiteral(resourceName: "ClickedBikingIcon"), #imageLiteral(resourceName: "ClickedConcertIcon"), #imageLiteral(resourceName: "ShoppingIcon"), #imageLiteral(resourceName: "EatingIcon"), #imageLiteral(resourceName: "DrinkingIcon"), #imageLiteral(resourceName: "ReligonIcon"), #imageLiteral(resourceName: "VideoIcon"), #imageLiteral(resourceName: "MusicIcon"), #imageLiteral(resourceName: "DancingIcon"), #imageLiteral(resourceName: "TechIcon"), #imageLiteral(resourceName: "EducationIcon"), #imageLiteral(resourceName: "FinanceIcon"), #imageLiteral(resourceName: "CarsIcon"), #imageLiteral(resourceName: "PhotoIcon")]
    let titleArr = ["Basketball", "Barbeque", "Dog Park", "Badminton", "Golf", "Reading", "Hiking", "Picnic", "Volleyball", "Soccer", "Swimming", "Walking", "Tennis", "Baseball/Softball", "Football", "Beach", "Workout", "Cricket", "Biking", "Concert", "Shopping", "Food", "Drinking", "Religous Activites", "Video Games", "Music", "Dancing", "Technology", "Education", "Finance", "Cars", "Photography"]
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArr.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AudioServicesPlaySystemSound(1519)
        print(indexPath.row)
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        if(clickedArr[indexPath.row] == false){
            cell.interestsImage.image = selImageArr[indexPath.row]
            ref.child("Users").child(Auth.auth().currentUser!.uid).child("Interests").childByAutoId().setValue(titleArr[indexPath.row])
            
            clickedArr[indexPath.row] = true
        }
        else{
            ref.child("Users").child(Auth.auth().currentUser!.uid).child("Interests").observe(.childAdded, with: { (snapshot) in
                if(snapshot.value as? String == self.titleArr[indexPath.row]){
                    self.ref.child("Users").child(Auth.auth().currentUser!.uid).child("Interests").child(snapshot.key).removeValue()
                    Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Interests").removeAllObservers()
                }
            })
            cell.interestsImage.image = imageArr[indexPath.row]
            clickedArr[indexPath.row] = false
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        ref.child("Users").child(Auth.auth().currentUser!.uid).child("Interests").observe(.childAdded, with: { (snapshot) in
                if(snapshot.value as! String == self.titleArr[indexPath.row]){
                    cell.interestsImage.image = self.selImageArr[indexPath.row]
                    self.clickedArr[indexPath.row] = true
                }
        })
        if(cell.interestsImage.image == nil){
             cell.interestsImage.image = imageArr[indexPath.row]
        }
        cell.interestsTitle.text = titleArr[indexPath.row]
        if(clickedArr[indexPath.row] == false){
            cell.interestsImage.image = imageArr[indexPath.row]
        }
        else{
            cell.interestsImage.image = selImageArr[indexPath.row]
        }
        return cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor.init(red: 48/255, green: 55/255, blue: 59/255, alpha: 1)
        collectionView.dataSource = self
        collectionView.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        
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

