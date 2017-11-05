//
//  SignInViewController.swift
//  theNightlife
//
//  Created by Jeffry Sandoval on 11/4/17.
//  Copyright © 2017 Jeffry Sandoval. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class SignInViewController: UIViewController {

    @IBOutlet weak var signInSelector: UISegmentedControl!
    
    @IBOutlet weak var signInLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var passwordConfirmLabel: UILabel!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    
    
    
    var isSignIn:Bool = true
    var ref:DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()    // var connected to firebase database

        passwordConfirmLabel.isHidden = true
        passwordConfirmTextField.isHidden = true
        usernameLabel.isHidden = true
        usernameTextField.isHidden = true
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInSelectorChanged(_ sender: UISegmentedControl) {
        
        isSignIn = !isSignIn   //when the segmented control is switched to the "Register" side, the boolean value of this var has a value of false
        
        //Check the bool and set the button and label's text
        if isSignIn{
            signInLabel.text = "Sign In"
            signInButton.setTitle("Sign In", for: .normal)
            
            passwordConfirmLabel.isHidden = true
            passwordConfirmTextField.isHidden = true
            usernameLabel.isHidden = true
            usernameTextField.isHidden = true
            
            
            
        }
        else {
            signInLabel.text = "Register"
            signInButton.setTitle("Register", for: .normal)
            
            passwordConfirmLabel.isHidden = false
            passwordConfirmTextField.isHidden = false
            usernameLabel.isHidden = false
            usernameTextField.isHidden = false
            
        }
        
    }
    
        
    @IBAction func signInButtonTapped(_ sender: Any) {
        
        let defaultPic = "https://firebasestorage.googleapis.com/v0/b/thenightlife-9ab23.appspot.com/o/nopicture.jpg?alt=media&token=c6621ec3-3d0e-41d4-bae8-211bfe6f9dcb"

       let owner = "false"
        
        
        if let email = emailTextField.text, let pass = passwordTextField.text, let username = usernameTextField.text

        {
            
        //Check if it's sign in or register
        if isSignIn{
            // Sign in the user with Firebase
            Auth.auth().signIn(withEmail: email, password: pass, completion: { (user, error) in
                
                if error != nil {
                    self.signInLabel.text = "Incorrect email or password, try again!"
                    
                }
                else {
                    // User is found, go to home screen
                    self.performSegue(withIdentifier: "goToHome", sender: self) //sender is who is calling or performing this segue. self is view controller
                    
                }
                
            })
            
            
        }
        else{
            //Register the user with Firebase
            
            if (emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! || (passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! || (passwordConfirmTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! || (usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
                signInLabel.text = "All fields must completed!"
                print("error in missing")
                return
            }
            
            
            
            if (passwordTextField.text?.characters.count)! < 6 {
                signInLabel.text = "Password must be 6 characters or longer!"
                print("error in pwd length")
                return
            }
            
            
            
            if (emailTextField.text?.contains("@"))!, (emailTextField.text?.contains(".com"))! {
                print("excellent")
            } else {
                signInLabel.text = "Invalid email input"
                print("error in email input")
                return
            }
            
            
            //if they dont match, what happens?
            if passwordTextField.text != passwordConfirmTextField.text {
                signInLabel.text =  "Passwords don't match!"
                print("pwd dont match")
                return
                
            }
            
            
            Auth.auth().createUser(withEmail: email, password: pass, completion: { (user, error) in
                
                
                
                // Check that user isn't nil
                if error != nil {
                    self.signInLabel.text = "User with this email already exists!"
                    return
                }
                else{
                    // New user profile is created, and then user is sent to homescreen
                    self.performSegue(withIdentifier: "goToHome", sender: self)
                    let values = ["username": username, "email": email, "profilepic": defaultPic, "isOwner": owner]
                    
                    self.ref?.child("users").child((user?.uid)!).setValue([values]) //where all the users are stored, and are identified by their email
                }
                
                
            })
            
            
        }
        
    }
        
        
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Dismiss the keyboard when the view is tapped on
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        passwordConfirmTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        
        
        
    }
    
}

    
        
        

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    



