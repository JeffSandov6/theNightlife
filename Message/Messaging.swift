//
//  Messaging.swift
//  theNightlife
//
//  Created by Jeffry Sandoval on 11/4/17.
//  Copyright © 2017 Jeffry Sandoval. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth



fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}







class Messaging: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navTitle: UINavigationItem!
    
    let ref = Database.database().reference()
    
    let cellId = "cellId"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchUserAndSetUpNavBarTitle()
        
        
        
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        //observeMessages()
        
        //observeUserMessages()
        
        tableView.allowsMultipleSelectionDuringEditing = true  ////for deleting
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { //adds delete option
        
        return true
        
    }
    
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { //what will happen when we swipe to delete
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                    print("failed to delete messages")
                    return
                }
                
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
                
            })
        }
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    
    
    func observeUserMessages() {
        
        let uid = Auth.auth().currentUser?.uid
        
        
        
        let ref = Database.database().reference().child("user-messages").child(uid!)
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid!).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                
                self.fetchMessageWithMessageId(messageId: messageId)
                
                
                
            })
            
        })
        ref.observe(.childRemoved, with: { (snapshot) in
            
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
            
            
        })
        
        
        
    }
    
    
    
    
    
    
    
    
    
    private func fetchMessageWithMessageId(messageId: String) {
        
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        
        
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String: AnyObject] {
                let message = Message()
                
                
                
                message.fromId = dict["fromId"] as! String?
                message.text = dict["text"] as! String?
                message.timestamp = dict["timestamp"] as! NSNumber?
                message.toId = dict["toId"] as! String?
                
                //self.messages.append(message)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                    
                    
                }
                
                self.attemptReloadOfTable()
                
            }
            
        })
    }
    
    
    
    
    private func attemptReloadOfTable() {
        
        self.timer?.invalidate()
        print("we just canceled our timer")
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        print("Schedule a table reload in 0.1 seconds")
        
    }
    
    
    
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        
        
        self.messages = Array(self.messagesDictionary.values)
        
        self.messages.sort(by:{ (message1, message2) -> Bool in
            
            return message1.timestamp?.int32Value > message2.timestamp?.int32Value
        })
        
        DispatchQueue.main.async(execute:{
            
            self.tableView.reloadData()
            
        })
        
    }
    
    
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        
        
        return cell
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId).child("0")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String : AnyObject]
                else {
                    return
            }
            
            //let user = User(dictionary: dict)
            let user = User()
            
            user.username = dict["username"] as! String?
            
            user.email = dict["email"] as! String?
            
            user.profilepic = dict["profilepic"] as! String?
            
            user.id = chatPartnerId
            
            self.showChatControllerForUser(user: user)
            
            
            
        })
        
    }
    
    
    @IBAction func tapOnCompose(_ sender: Any) {
        
        handleNewMessage()
        
    }
    
    
    
    func fetchUserAndSetUpNavBarTitle() {
        let UserID = Auth.auth().currentUser?.uid
        
        
        ref.child("users").child(UserID!).child("0").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String : AnyObject]
            {
                let user = User()
                //let user = User(dictionary: dict)
                
                user.username = dict["username"] as! String?
                user.profilepic = dict["profilepic"] as! String?
                user.id = snapshot.key
                
                self.setupNavBarWithUser(user: user)
                
            }
            
            
        })
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    func setupNavBarWithUser(user: User) {
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profilepic = user.profilepic {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profilepic)
        }
        
        
        
        containerView.addSubview(profileImageView)
        
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        
        nameLabel.text = user.username
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        
        self.navTitle.titleView = titleView
        
        
    }
    
    func showChatControllerForUser(user: User){
        let chatLogController = ChatLogController(collectionViewLayout:UICollectionViewFlowLayout())
        chatLogController.user = user
        
        let navController = UINavigationController(rootViewController: chatLogController)
        present(navController, animated: true, completion: nil)
        
        //navigationController?.pushViewController(chatLogController, animated: true)
        
    }
    
    
    
    
    func handleNewMessage() {
        
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}





