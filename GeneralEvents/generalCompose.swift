//
//  generalCompose.swift
//  theNightlife
//
//  Created by Jeffry Sandoval on 11/4/17.
//  Copyright © 2017 Jeffry Sandoval. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class generalCompose: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var titleTextView: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    var ref:DatabaseReference?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        titleTextView.delegate = self
        textView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentCharacterCount = textView.text?.characters.count
        if (range.length + range.location > currentCharacterCount!){
            return false
        }
        let newLength = currentCharacterCount! + text.characters.count - range.length
        return newLength <= 335
        
        
        
        
        
    }
    
    
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = titleTextView.text?.characters.count
        if (range.length + range.location > currentCharacterCount!){
            return false
        }
        let newLength = currentCharacterCount! + string.characters.count - range.length
        return newLength <= 26
        
        
        
        
    }

    
    
    
    
    
    
    @IBAction func addPost(_ sender: Any) {
        if (titleTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! || (textView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            
            return
            
        }
        
        
        let UserID = Auth.auth().currentUser!.uid
        
        
        self.ref?.child("users").child(UserID).child("0").observe(.value, with: { (snapshot) in
            
            
            let dict = snapshot.value as! [String: AnyObject]
            
            let username = dict["username"] as! String?
            
            let title = self.titleTextView.text
            
            let text = self.textView.text
            
            let timestamp = NSDate().timeIntervalSince1970
            
            let values = ["userId": UserID, "username": username!, "title": title!, "text": text!, "timestamp": timestamp] as [String : Any]
            
            
            
            self.ref?.child("generalPosts").childByAutoId().setValue(values)
            
        })
        
        
        
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelPost(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)

    }
    

}
