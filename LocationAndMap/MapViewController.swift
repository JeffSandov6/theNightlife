//
//  MapViewController.swift
//  theNightlife
//
//  Created by Jeffry Sandoval on 11/4/17.
//  Copyright © 2017 Jeffry Sandoval. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
import MapKit
import FirebaseDatabase
import FirebaseAuth
import GeoFire
import FirebaseStorage
import Firebase



class MapViewController: UIViewController, GMSMapViewDelegate {
    
    let uid = Auth.auth().currentUser!.uid
    
    var geofireRef:DatabaseReference?
    
    var ref:DatabaseReference?
    
    let storageRef = Storage.storage()
    
    
    var currentActivity = ""
    
    var currentLocation = CLLocation()
    
    
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    
    var manager = CLLocationManager()
    var currentMarker = GMSMarker()
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.distanceFilter = 10
        manager.startUpdatingLocation()
        
        
        
        //mapView.delegate = self
        
        

        
        ref = Database.database().reference()
        
        
        geofireRef = Database.database().reference()
        
        let User = Auth.auth().currentUser!.uid
        
        self.ref?.child("users").child(User).child("activity").observe(.value, with: { (snapshot) in
            
            
            
            
            
            let dict = snapshot.value as! [String: AnyObject]
            
            let activity = dict["currentActivity"] as! String?
            
            
            
            if activity == "isParty" {
                
                self.currentActivity = "Partiers"
                print("yeah this is the map with partiers on it")
                print(self.currentActivity)
                
            } else if activity == "isGeneral"{
                
                self.currentActivity = "Generalers"
                print("yeah this is the map with generalers on it")
                print(self.currentActivity)
                
                
            } else {
                print("theres a mistake")
            }
            
            
            
            
            
            
        })
        
        
        
        
        
        
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.868,
                                              longitude: 151.2086,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        do {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        
        
        
        mapView.isHidden = false
        mapView.settings.scrollGestures = true
        self.mapView.delegate = self
        
        
        //mapView.frame = CGRect(x: 10, y: 60, width: 300, height: 600)
        
        
        //mapView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mapView)
        view.addSubview(navBar)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //
        print("its being called") //these are used for reference and can be deleted
        self.currentLocation = locations[0]
        print(self.currentLocation)
        print("loc manager being called")
        
        
    }
    
    
    
    
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("marker has been tapped")
        
        let uid = Auth.auth().currentUser?.uid
        
        if uid != marker.userData as? String {
            
            
            
            let chatPartnerId = marker.userData as? String!
            
            
            self.ref?.child("users").child(chatPartnerId!).child("0").observe(.value, with: { (snapshot) in
                
                let dict = snapshot.value as! [String: AnyObject]
                
                
                let user = User()
                
                user.username = dict["username"] as! String?
                
                user.email = dict["email"] as! String?
                
                user.profilepic = dict["profilepic"] as! String?
                
                user.id = chatPartnerId
                
                self.showChatControllerForUser(user: user)
                
                
                
                
                
                
                
                
                let username = dict["username"] as! String?
                
                let email = dict["email"] as! String?
                
                let profilepic = dict["profilepic"] as! String?
                
                let values = ["username": username, "email": email, "profilepic": profilepic]
                
                
                self.ref?.child("users").child(uid!).child("friends").child(chatPartnerId!).updateChildValues(values)
                
                
                
                
                self.ref?.child("users").child(uid!).child("0").observe(.value, with: { (newsnapshot) in //adds messager as a friend
                    
                    let newdict = newsnapshot.value as! [String : AnyObject]
                    
                    let username = newdict["username"] as! String?
                    
                    let email = newdict["email"] as! String?
                    
                    let profilepic = newdict["profilepic"] as! String?
                    
                    let newvalues = ["username": username, "email": email, "profilepic": profilepic]
                    
                    self.ref?.child("users").child(chatPartnerId!).child("friends").child(uid!).updateChildValues(newvalues)
                    
                })
                
                
                
                
                
                
                
                
                
                
                // Have to add some sort of push notification to show that you have a new message
                
                
                
                
                
            })
            
        } else {
            return
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    func showChatControllerForUser(user: User){
        let chatLogController = ChatLogController(collectionViewLayout:UICollectionViewFlowLayout())
        chatLogController.user = user
        
        let navController = UINavigationController(rootViewController: chatLogController)
        present(navController, animated: true, completion: nil)
        
        //navigationController?.pushViewController(chatLogController, animated: true)
        
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func updateMyLocation(_ sender: Any) {
        
        let geoFire = GeoFire(firebaseRef: geofireRef?.child(currentActivity))
        
        
        
        
        let UserID = Auth.auth().currentUser!.uid
        
        geoFire!.setLocation(currentLocation, forKey: UserID) { (error) in
            if (error != nil) {
                print("Fuck")
            } else {
                print("saved location succesfully")
                print("this is it '\(self.currentLocation)' ")
            }
        }
        
    }
    
    
    @IBAction func removeLocation(_ sender: Any) {
        let geoFire = GeoFire(firebaseRef: geofireRef?.child(currentActivity))
        //let UserID = Auth.auth().currentUser!.uid
        
        geoFire!.removeKey(uid)
        print("hello")
    }
    
    

    @IBAction func refreshMap(_ sender: Any) {
        
        mapView.clear()
        
        
        let geoFire = GeoFire(firebaseRef: geofireRef?.child(currentActivity))
        
        
        
        
        
        
        //let span = MKCoordinateSpanMake(90 - currentLocation.coordinate.latitude, 180 - currentLocation.coordinate.latitude)
        
        
        
        
        let span = MKCoordinateSpanMake(1, 1)
        let region = MKCoordinateRegionMake(currentLocation.coordinate, span)
        
        
        let regionQuery = geoFire!.query(with: region)
        
        regionQuery?.observe(.keyEntered, with: { (key, location) in
            
            //print("Key '\(key)' entered the search area and is at location '\(location)'  yaaaay")
            
            
            self.ref?.child("users").child(key!).child("0").observe(.value, with: { (snapshot) in
                
                
                if ( snapshot.value is NSNull ) {
                    print("not found")
                    
                } else {
                    print("in snap")
                    
                    let dict = snapshot.value as! [String: AnyObject]
                    
                    
                    let username = dict["username"] as! String?
                    
                    //let email = dict["email"] as! String?
                    
                    let downloadURL = dict["profilepic"] as! String?
                    
                    let mapId = key
                    
                    
                    let imageRef = self.storageRef.reference(forURL: downloadURL!)
                    
                    let marker = GMSMarker()
                    
                    
                    
                    
                    
                    marker.userData = mapId
                    
                    
                    marker.position = (location?.coordinate)!
                    
                    marker.title = username
                    
                    marker.snippet = "Message User"
                    
                    
                    
                    imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        
                        if let error = error {
                            print(error.localizedDescription)
                            print("mistake here")
                        } else {
                            let image = UIImage(data: data!)
                            
                            
                            let scale: CGFloat = 0.0
                            let thisSize = CGSize(width: 60, height: 60)  //80,80
                            
                            UIGraphicsBeginImageContextWithOptions(thisSize, true, scale)
                            image!.draw(in: CGRect(origin: CGPoint.zero, size: thisSize))
                            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
                            
                            
                            
                            
                            let newImage = self.maskRoundedImage(scaledImage!, radius: 30) //40
                            
                            
                            marker.icon = newImage.withRenderingMode(.alwaysTemplate)
                            
                            
                            
                        }
                        
                        
                        
                        
                        marker.map = self.mapView
                    }
                    
                    
                }
                
                
                
            }) { (error) in
                print(error.localizedDescription)
                print("this wont work")
            }
            
            
            
        })
        
    }
    
    
    
    @IBAction func returnToNav(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: currentActivity)
        self.present(nav, animated: true, completion: nil)
    }
    

    func maskRoundedImage(_ image: UIImage, radius: Float) -> UIImage {
        
        let imageView: UIImageView = UIImageView(image: image)
        var layer: CALayer = CALayer()
        
        
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.clipsToBounds = true
        
        layer = imageView.layer
        
        
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(radius)
        //layer.borderWidth = 4.0
        //layer.borderColor = UIColor.white.cgColor
        
        
        
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, UIScreen.main.scale)
        
        //UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        return roundedImage!
        
    }
    
    


}
