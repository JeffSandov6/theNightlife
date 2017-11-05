//
//  generalEvents.swift
//  theNightlife
//
//  Created by Jeffry Sandoval on 11/4/17.
//  Copyright © 2017 Jeffry Sandoval. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase




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


fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}



class generalPostsCells: UITableViewCell{
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var Username: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var theText: UITextView!
    
    
}


class generalEvents: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var ref:DatabaseReference?
    
    
    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        ref = Database.database().reference()
        
        getPosts()
        
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
    }
    
    var posts = [Posts]()  //messages
    var postsDictionary = [String: Posts]() //messagesdictionary
    
    
    
    
    
    
    func getPosts() {
        
        ref?.child("generalPosts").observe(.childAdded, with: { (snapshot) in //also have to add a child deleted
            
            let postId = snapshot.key
            
            self.getPostWithId(postId: postId)
            
            
        })
        
        ref?.observe(.childRemoved, with: { (snapshot) in
            self.postsDictionary.removeValue(forKey: snapshot.key)
            
            self.attemptReloadOfTable()
        })
        
        
        
        
        
        
    }
    
    
    private func getPostWithId(postId: String) {
        
        let postReference = Database.database().reference().child("generalPosts").child(postId)
        
        postReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String: AnyObject] {
                let post = Posts()
                
                post.text = dict["text"] as! String?
                post.posterId = dict["userId"] as! String?
                post.timestamp = dict["timestamp"] as! NSNumber?
                post.username = dict["username"] as! String?
                post.title = dict["title"] as! String?
                post.postId = postId
                
                
                //postsDictionary.append(post)
                
                
                
                
                
                self.postsDictionary[snapshot.key] = post
                
                
            }
            self.attemptReloadOfTable()
            
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
        
        
        self.posts = Array(self.postsDictionary.values)
        
        self.posts.sort(by:{ (post1, post2) -> Bool in
            
            return (post1.timestamp?.int32Value)! > (post2.timestamp?.int32Value)!
        })
        
        DispatchQueue.main.async(execute:{
            
            self.tableView.reloadData()
            
        })
        
    }
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return postData.count
        
        return posts.count
        
        
    }
    
    
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell:generalPostsCells = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! generalPostsCells
        
        let post = posts[indexPath.row]
        
        if let id = post.postId {
            
            let ref = Database.database().reference().child("generalPosts").child(id)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dict = snapshot.value as? [String: AnyObject] {
                    
                    
                    cell.Username.text = dict["username"] as! String?
                    cell.title.text = dict["title"] as! String?
                    cell.theText.text = dict["text"] as! String?
                    
                    if let seconds = post.timestamp?.doubleValue {
                        let timestampDate = NSDate(timeIntervalSince1970: seconds)
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMM d, h:mm a"
                        
                        
                        cell.timeLabel.text = dateFormatter.string(from: timestampDate as Date)
                        
                    }
                }
                
                
                
                
            })
            
            
        }
        
        return cell
        
    }
    
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let uid = Auth.auth().currentUser?.uid
        
        
        let post = posts[indexPath.row]
        
        let posterId = post.posterId
        
        
        if uid != posterId {
            
            
            let ref = Database.database().reference().child("users").child(posterId!).child("0")
            
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
                
                user.id = posterId
                
                self.showChatControllerForUser(user: user)
                
                
                
                
                
                let username = dict["username"] as! String?
                
                let email = dict["email"] as! String?
                
                let profilepic = dict["profilepic"] as! String?
                
                let values = ["username": username, "email": email, "profilepic": profilepic]
                
                
                self.ref?.child("users").child(uid!).child("friends").child(posterId!).updateChildValues(values)
                
                self.ref?.child("users").child(uid!).child("0").observe(.value, with: { (newsnapshot) in
                    
                    let newdict = newsnapshot.value as! [String : AnyObject]
                    
                    let username = newdict["username"] as! String?
                    
                    let email = newdict["email"] as! String?
                    
                    let profilepic = newdict["profilepic"] as! String?
                    
                    let newvalues = ["username": username, "email": email, "profilepic": profilepic]
                    
                    self.ref?.child("users").child(posterId!).child("friends").child(uid!).updateChildValues(newvalues)
                    
                })
                
                
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
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { //adds delete option
        
        let uid = Auth.auth().currentUser?.uid
        
        let post = posts[indexPath.row]
        
        let posterId = post.posterId
        
        
        if uid == posterId {
            
            return true
        } else {
            return false
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { //what will happen when we swipe to delete
        
        
        let post = posts[indexPath.row]
        
        if let postId = post.postId {
            
            Database.database().reference().child("generalPosts").child(postId).removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                    print("failed to delete messages")
                    return
                }
                
                self.postsDictionary.removeValue(forKey: postId)
                self.attemptReloadOfTable()
                
            })
        }
        
    }
    
    
}











