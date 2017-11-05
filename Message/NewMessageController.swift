//
//  NewMessageController.swift
//  theNightlife
//
//  Created by Jeffry Sandoval on 11/4/17.
//  Copyright © 2017 Jeffry Sandoval. All rights reserved.
//


import UIKit
import FirebaseDatabase
import FirebaseAuth


class NewMessageController: UITableViewController {
    
    
    let cellID = "cellID"
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationController?.navigationBar.barTintColor = UIColor.darkGray
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        
        fetchUser()
        
    }
    
    
    func fetchUser() {
        
        let UserID = Auth.auth().currentUser?.uid
        
        Database.database().reference().child("users").child(UserID!).child("friends").observe(.childAdded, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String: AnyObject] {
                //let user = User(dictionary: dict)
                
                
                let user = User()
                //user.setValuesForKeys(dict)
                
                user.username = dict["username"] as! String?
                
                user.email = dict["email"] as! String?
                
                user.profilepic = dict["profilepic"] as! String?
                
                user.id = snapshot.key
                
                
                
                
                self.users.append(user)
                
                
                DispatchQueue.main.async(execute:{
                    self.tableView.reloadData()
                    
                })
                
                
            }
            
            
            
            
        })
    }
    
    
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        //below this is just a hack for now, bc we arent using storyboards
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.username
        
        cell.detailTextLabel?.text = user.email
        
        
        
        if let profilePic = user.profilepic {
            
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profilePic)
            
        }
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
    
    
    var messagesController: Messaging?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true){
            print("dismissed")
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user: user)
            
            
            
        }
    }
    
    
    
}














