//
//  MessagesTableViewController.swift
//  bulletinboard
//
//  Created by bhavik on 14/12/18.
//  Copyright © 2018 bhavik. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FacebookCore
import FacebookLogin
import SwiftyJSON
import FirebaseDatabase
import FirebaseStorage

class MessagesTableViewController: UITableViewController {
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    var users = [Users]()
    var messages = [Message]()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("inside main message")
        navigationBarItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-undo-25"), style: .plain, target: self, action: #selector(cancelBtnPressed(sender:)))
//        navigationBarItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBtnPressed(sender:)))
//        navigationBarItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(chatBtnPressed(sender:)))
        fetchUser()
        observeMessages()
        
      //  navigationBarItem.titleView = "Bulletin Board"
    }
    
    func observeMessages(){
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded) { (snapshot) in
            print(snapshot)
            if let dictionary = snapshot.value as? [String: AnyObject]{
                print("inside hereeee")
            let message = Message()
            message.fromId = dictionary["fromId"] as! String
            message.text = dictionary["text"] as! String
            message.toId = dictionary["toId"] as! String
          //  message.timestamp = dictionary["timestamp"] as! NSNumber
            print(message)
            self.messages.append(message)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
//        self.navigationBarItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: "cancelBtnPressed")
//        self.navigationBarItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: "chatBtnPressed")
    }
//    @objc func chatBtnPressed(sender: UIBarButtonItem){
//        performSegue(withIdentifier: "chatLogSeague", sender: self)
//    }
    
    @objc func cancelBtnPressed(sender: UIBarButtonItem){
    dismiss(animated: true, completion: nil)
    }
    func fetchUser(){
        Database.database().reference().child("users").observe(.childAdded, with: {(snapshot) in
            //print(snapshot)
            if let dictioanry = snapshot.value as? [String: Any]{
                let id = snapshot.key
                let name = dictioanry["name"]
                let email = dictioanry["email"]
                if Auth.auth().currentUser?.uid != id{
                    let user = Users(id:id as! String,name: name as! String, email: email as! String)
              //  print(user.name)
                    self.users.append(user)
                    self.tableView.reloadData()
                }
            }
            
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatLogSeague"{
             if let indexPath = tableView.indexPathForSelectedRow {
                print("seague index")
            
            let userid = users[indexPath.row].id!
                print("user",userid)
            let controller = (segue.destination as! ChatLogController) as ChatLogController
            controller.user = users[indexPath.row]
                print("messages array",messages)
                for message in messages{
                    if message.toId == userid{
                        controller.message = message
                    }
                }
            print( controller.user )
                print("controller message",controller.message)
            print("inside searchActive")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     //   dismiss(animated: true, completion: nil)
        print("dismiss completed")
        
        performSegue(withIdentifier: "chatLogSeague", sender: self)
    
    }
   

}
