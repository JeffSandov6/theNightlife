//
//  businessNav.swift
//  theNightlife
//
//  Created by Jeffry Sandoval on 11/5/17.
//  Copyright © 2017 Jeffry Sandoval. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class businessNav: UIViewController {
    
    let uid = Auth.auth().currentUser!.uid
    
    var ref:DatabaseReference?
    
    var isOwner = ""

    @IBOutlet weak var updateBusinessButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let User = Auth.auth().currentUser!.uid
        
        self.ref?.child("users").child(User).child("0").observe(.value, with: { (snapshot) in

            let dict = snapshot.value as! [String: AnyObject]
            
            let ownerStatus = dict["isOwner"] as! String?
            
            if ownerStatus == "false" {
                
                self.isOwner = "false"
                
            } else {
                
                self.isOwner = "true"
                
            }
        
            
        })
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goToBusinessProfile(_ sender: Any) {
        
        if self.isOwner == "false" {
            updateBusinessButton.setTitle("You do NOT have a business profile!", for: .normal)
            
        } else {
            goToBusinessProfile()
            
        }
        
        
    }
    
    
    func goToBusinessProfile() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "businessProfile")
        self.present(nav, animated: true, completion:  nil)
        
        
        
    }
    
    
}
