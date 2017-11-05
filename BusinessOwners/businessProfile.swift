//
//  businessProfile.swift
//  theNightlife
//
//  Created by Jeffry Sandoval on 11/5/17.
//  Copyright © 2017 Jeffry Sandoval. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class businessProfile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let uid = Auth.auth().currentUser!.uid
    
    var ref:DatabaseReference?
    var isOwner = ""
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var bioNextEvent: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var numLabel: UILabel!
    
    let storageRef = Storage.storage().reference()
    let databaseRef = Database.database().reference()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProfile()
        
        let User = Auth.auth().currentUser!.uid
        
        self.ref?.child("users").child(User).child("0").observe(.value, with: { (snapshot) in
            
            let dict = snapshot.value as! [String: AnyObject]
            
            let ownerStatus = dict["isOwner"] as! String?
            
            if ownerStatus == "false" {
                
                self.isOwner = "false"
                self.saveButton.setTitle("Save", for: .normal)
                
            } else {
                
                self.isOwner = "true"
                self.saveButton.setTitle("Check In", for: .normal)
                
            }
            
            
        })
        
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func uploadImageButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func saveChanges(_ sender: Any) {
        if self.isOwner == "false" {
            incrementCounter()
            
        } else {
            saveChanges()()

        }
        
        
        
    }
    
    
    func setupProfile(){
        
        let UserID = Auth.auth().currentUser!.uid
        
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        
        databaseRef.child("users").child(UserID).child("BusinessProfile").observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            
            
            if let dict = snapshot.value as? [String : AnyObject]
            {
                
                
                self.bioNextEvent.text = dict["Bio"] as! String?
                self.businessNameLabel.text = dict["Name"] as! String?
                self.numLabel.text = dict["CheckIn"] as! String?
                if let profileImageURL = dict["businesspic"] as! String?
                {
                    let url = URL(string: profileImageURL)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        if error != nil{
                            print(error!)
                            return
                        }
                        
                        DispatchQueue.main.sync {
                            self.profileImage?.image = UIImage(data: data!)
                            
                            
                        }
                    }).resume()
                }
            }
        })
        
    }
    
    
    
    ////////////////////////////////////////////////////////////////////
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            selectedImageFromPicker = editedImage
            
        }else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            profileImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    ////////////////////////////////////////////
    
    
    func saveChanges(){
        let imageName = UUID().uuidString
        
        let storedImage = storageRef.child("profileImages").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(self.profileImage.image!, 0.1)
        {
            storedImage.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!)
                    return
                }
                storedImage.downloadURL(completion: { (url, error) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    if let urlText = url?.absoluteString{
                        self.databaseRef.child("users").child(Auth.auth().currentUser!.uid).child("BusinessProfile").updateChildValues(["businesspic" : urlText], withCompletionBlock: { (error, ref) in
                            
                            if error != nil{
                                print(error!)
                                return
                            }
                            
                            
                        })
                    }
                    
                })
                
            })
            
        }
    }
    
    
    
    func incrementCounter() {
       
        var counter = ""
        databaseRef.child("users").child(uid).child("BusinessProfile").observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as! [String: AnyObject]

            counter = (dict["CheckIn"] as! String?)!
            
            
        
        
            let myInt = Int(counter)
            let newInt = myInt! + 1
            let newCounter = String(describing: newInt)
            self.databaseRef.child("users").child(self.uid).child("BusinessProfile").updateChildValues(["CheckIn" : newCounter])
            self.numLabel.text = newCounter
            
            
        })

        
    }
    
    
    
    
    
    @IBAction func `return`(_ sender: Any) {
        returnToPage()
    }
    

    
    @objc func returnToPage () {
        dismiss(animated: true, completion: nil)
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
