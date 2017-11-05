//
//  ProfileViewController.swift
//  theNightlife
//
//  Created by Jeffry Sandoval on 11/4/17.
//  Copyright © 2017 Jeffry Sandoval. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage


class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    let storageRef = Storage.storage().reference()
    let databaseRef = Database.database().reference()
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupProfile()

    }
    
    
    @IBAction func uploadImageButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func saveChanges(_ sender: Any) {
        saveChanges()
    }
    
    func setupProfile(){
        
        let UserID = Auth.auth().currentUser!.uid
        
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        
        databaseRef.child("users").child(UserID).child("0").observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            
            
            if let dict = snapshot.value as? [String : AnyObject]
            {
                
                
                
                self.usernameLabel.text = dict["username"] as! String?
                if let profileImageURL = dict["profilepic"] as! String?
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
                        self.databaseRef.child("users").child(Auth.auth().currentUser!.uid).child("0").updateChildValues(["profilepic" : urlText], withCompletionBlock: { (error, ref) in
                            
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}

