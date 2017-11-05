//
//  homePage.swift
//  theNightlife
//
//  Created by Jeffry Sandoval on 11/4/17.
//  Copyright © 2017 Jeffry Sandoval. All rights reserved.
//

import UIKit
import GeoFire
import FirebaseDatabase
import FirebaseAuth
import CoreLocation


class homePage: UIViewController, CLLocationManagerDelegate {

    var ref:DatabaseReference?
    var geofireRef:DatabaseReference?
    var manager = CLLocationManager()
    var center = CLLocation()
    
    var currentLocation = CLLocation()
    
    let firebaseAuth = Auth.auth()
    
    
    let UserID = Auth.auth().currentUser!.uid
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        
        
        geofireRef = Database.database().reference()
        ref = Database.database().reference()
    }

    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //let location = locations[0] // gets the first index in the array CLLocation, which always puts the most updated position in the first index
        
        self.currentLocation = locations[0]
        
        //let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        //self.center = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logout(_ sender: Any) {
        
        let geoFirePartiers = GeoFire(firebaseRef: geofireRef?.child("Partiers"))
        let geoFireGeneralers = GeoFire(firebaseRef: geofireRef?.child("Generalers"))

        
        geoFirePartiers?.removeKey(UserID)
        geoFireGeneralers?.removeKey(UserID)
        
        do {
            try firebaseAuth.signOut()
            print("hi")
            
        } catch let signOutError as NSError {
            print ("Error signing out: %A", signOutError)
            
        }


    
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let nav = storyboard.instantiateViewController(withIdentifier: "SignIn")
    self.present(nav, animated: true, completion:  nil)

    

    }
    
    

    @IBAction func partyToNav(_ sender: UIButton) {
        self.ref?.child("users").child(UserID).child("activity").setValue(["currentActivity": "isParty"])

    }
    
    
    
    
    
    @IBAction func generalToNav(_ sender: Any) {
        
        self.ref?.child("users").child(UserID).child("activity").setValue(["currentActivity": "isGeneral"])

    }
    
    
    
    
    
    

}
