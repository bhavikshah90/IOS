//
//  ChatLogController.swift
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

class ChatLogController: UIViewController,UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
   var messages = [Message]()
    var message: Message?
   
    var textView: UITextView = {
        let tv = UITextView()
        return tv
    }()
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type message.."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    var user: Users?{
        didSet{
           // observeMessages()
        }
    }
    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        let messageRef = Database.database().reference().child("messages")
//        messageRef.observeSingleEvent(of: .value) { (snapshot) in
//            print(snapshot)
//            guard let dictionary = snapshot.value as? [String: Any]else{
//                return
//            }
//            print("message is ",self.message?.toId)
//            print("uid",uid)
//            //if self.message?.toId == dictionary["toId"] as! String?{
//                print("yes")
//               // if uid == dictionary["fromId"] as! String?{
//                    print("right")
//                    let m1 = Message()
//                    m1.fromId = dictionary["fromId"] as! String?
//            print("m1",m1.fromId)
//
//
//                    m1.text = dictionary["text"] as! String?
//            print("m1",m1.text)
//                    m1.toId = dictionary["toId"] as! String?
//            print("m1",m1.toId)
//                    self.messages.append(m1)
//                    self.collectionView.reloadData()
//               // }
//           // }
//
//        }
        messageRef.observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            guard let dictionary = snapshot.value as? [String: Any]else{
                return
            }
            print("message is ",self.message?.toId)
            print("uid",uid)
            if self.message?.toId == dictionary["toId"] as! String?{
            print("yes")
             if uid == dictionary["fromId"] as! String?{
            print("right")
            let m1 = Message()
            m1.fromId = dictionary["fromId"] as! String?
            print("m1",m1.fromId)
            m1.text = dictionary["text"] as! String?
            print("m1",m1.text)
            m1.toId = dictionary["toId"] as! String?
            print("m1",m1.toId)
            self.messages.append(m1)
                }
            }
            if self.message?.toId == dictionary["fromId"] as! String?{
                print("yes")
                if uid == dictionary["toId"] as! String?{
                    print("right")
                    let m1 = Message()
                    m1.fromId = dictionary["fromId"] as! String?
                    print("m1",m1.fromId)
                    m1.text = dictionary["text"] as! String?
                    print("m1",m1.text)
                    m1.toId = dictionary["toId"] as! String?
                    print("m1",m1.toId)
                    self.messages.append(m1)
                }
            }
        }) { (err) in
            
        }
         self.collectionView.reloadData()
    }
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor.green
       // navigationBarItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(sender:)))
        navigationBarItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-undo-25"), style: .plain, target: self, action: #selector(cancelButtonPressed(sender:)))
        setupInputComponents()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.backgroundColor = UIColor.white
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        print("usercgfdg", user)
        navigationBarItem.title = user?.name
        print("messages", message)
        self.observeMessages()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        print("inside cell of message")
        print("message from previous screen",self.message?.text)
        print("message array",messages.count)
        cell.addSubview(textView)
        cell.textView.text = messages[indexPath.row].text
      //  cell.backgroundColor = UIColor.blue
//        for m in messages{
//            print("inside m")
//            cell.textView.text = m.text
//            print("celltexview", cell.textView.text)
//        }
        return cell
    }
    @objc func cancelButtonPressed(sender: UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)
    }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 50.0)
    }
    
    
    func setupInputComponents(){
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        containerView.addSubview(inputTextField)
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor,constant:8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor.black
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
    }
    

    @objc func handleSend(){
        print(123)
        print(inputTextField.text)
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user?.id
        let fromId = Auth.auth().currentUser?.uid
       // let timestamp :NSNumber = NSDate().timeIntervalSince1970
        let message = Message()
        let values = ["text": inputTextField.text!, "toId":toId,"fromId":fromId] as [String : Any]
        childRef.updateChildValues(values)
        message.text =  self.inputTextField.text!
        message.toId = toId
        message.fromId = fromId
        messages.append(message)
        print("inside handle")
        print("messages ", messages)
        self.collectionView.reloadData()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        self.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputTextField.resignFirstResponder()
    }
    
}
