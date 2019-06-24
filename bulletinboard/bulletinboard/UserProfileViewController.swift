//
//  UserProfileViewController.swift
//  bulletinboard
//
//  Created by bhavik on 10/12/18.
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

class UserProfileViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var btnSave: UIButton!
    var finalImage : String? = ""
    var photoTextField: String?=""
    var imagePicker = UIImagePickerController()
    var profilePicture: UIImage?
    @IBOutlet weak var btnUploadPhoto: UIButton!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var signOutButton: UIButton!
    var name:String?
    var isupdate:Bool = true
    var userArray = [String]()
    var ref : DatabaseReference?
//    Outlet weak var profilePicture: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        ref = Database.database().reference()
         self.checkUserProfile()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }

    func checkUserProfile(){
        let userID = Auth.auth().currentUser?.uid
        print("userid",userID)
        ref?.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String ?? ""
            let email = value?["email"] as? String ?? ""
            let profleImageURL = value?["profileImageUrl"] as? String ?? ""
            print("username",name)
            print("email",email)
            print("profleImageURL",profleImageURL)
            self.nameTextField.text = name
            self.emailTextField.text = email
            
            if profleImageURL == "No Image Found"{
            self.profilePic.image = UIImage(named: "whatsapp-dp-icon-4")
            }else
            {
            
                // Create a storage reference from the URL
                let storageRef = Storage.storage().reference(forURL: profleImageURL)
                // Download the data, assuming a max size of 1MB (you can change this as necessary)
                storageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) -> Void in
                    // Create a UIImage, add it to the array
                    guard let pfData = data
                        else{
                            self.profilePic.image = UIImage(named: "whatsapp-dp-icon-4")
                            return
                            }
                    self.profilePic.image = UIImage(data: pfData)
                }

            }
//            let user = User(username: username)
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signOutMethod(_ sender: Any) {
        do {
            print("signoutmethod")
            try Auth.auth().signOut()
            //UserDefaults.standard.removeObject(forKey: "users")
        
           self.performSegue(withIdentifier: "signout", sender: self)
            
            //completion(true)
        } catch _ {
            //completion(false)
        }
    }
    
  
    
    @IBAction func btnUploadPhotoPressed(_ sender: UIButton) {
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self
        let alert = UIAlertController(title: "Images", message: "Please Select an Option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Choose from photos", style: .default , handler:{ (UIAlertAction)in
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
    }

    
    @IBAction func btnUpdatePressed(_ sender: UIButton) {
        btnUploadPhoto.isEnabled = true
        btnUploadPhoto.isHidden = false
        btnSave.isHidden = false
        btnSave.isEnabled = true
        btnUpdate.isEnabled = false
        btnUpdate.isHidden = false
        isupdate = false
        
        }
    
    @IBAction func btnSavePressed(_ sender: UIButton) {
        btnUpdate.isEnabled = true
        btnUpdate.isHidden = false
        self.saveUserProfiletoFireBase()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("inside imagepicker")
        var locaPath = ""
        if let imgUrl = info[UIImagePickerControllerReferenceURL] as? URL{
            let imgName = imgUrl.lastPathComponent
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            locaPath = (documentDirectory?.appending(imgName))!
            
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.profilePicture = image
            let data = UIImageJPEGRepresentation(image,0.3)! as NSData
            data.write(toFile: locaPath, atomically: true)
            //let imageData = NSData(contentsOfFile: localPath!)!
            let photoURL = URL.init(fileURLWithPath: locaPath)//NSURL(fileURLWithPath: localPath!)
            print("photoURL",photoURL)
            finalImage = imgName
        }   //     var carNameString = "car"+String(count)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage   {
            // imageViewBox.image = image
            //image.accessibilityIdentifier = imageViewBox.description
            print("image name is ",image.accessibilityIdentifier)
        } else{
            print("Something went wrong")
            
        }
        photoTextField = locaPath
        dismiss(animated: true, completion: nil)
        print("Localpath is ",locaPath)
    }
    
    @IBAction func returnkeyPressed(_ sender: UITextField) {
        self.name = self.nameTextField.text
      //  self.returnkeyPressed(sender)
        self.resignFirstResponder()
    }
    func saveUserProfiletoFireBase(){
        print("inside saveUserprofile")
        let fileName = UUID().uuidString
        print("fileName ", fileName)
        guard let profileImageUploadData = UIImageJPEGRepresentation(self.profilePicture!, 0.3) else{
            let data = ["name": self.nameTextField.text,
                        "email": self.emailTextField.text,
                        "profileImageUrl": "No Image Found"] as [String : Any?]
            
            let user = Users(id: fileName,name: self.nameTextField.text!,email: self.emailTextField.text!)
            var ref = Database.database().reference()
            var users = ref.child("users").child((Auth.auth().currentUser?.uid)!)
            users.updateChildValues(data)
            self.showToast(message: "Profile Updated")
            self.dismiss(animated: true, completion: nil)
            print("Successfully updated user info into Firebase database")
            return}
        Storage.storage().reference().child("profileImages").child(fileName).putData(profileImageUploadData, metadata: nil) { (metadata, err) in
            if let err = err {
                //                Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user with error: \(err.localizedDescription)", delay: 3);
                return
            }
            //      guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user.", delay: 3); return }
            Storage.storage().reference().child("profileImages").child(fileName).downloadURL(completion: { (url, err) in
                guard let photourl = url else { print("Failed to save profile pic")
                    return }
                
                print("Successfully uploaded profile image into Firebase storage with URL:", photourl)
                
                let data = ["name": self.nameTextField.text,
                            "email": self.emailTextField.text,
                            "profileImageUrl": photourl.absoluteString] as [String : Any?]
                
                let user = Users(id: fileName,name: self.nameTextField.text!,email: self.emailTextField.text!)
                var ref = Database.database().reference()
                var users = ref.child("users").child((Auth.auth().currentUser?.uid)!)
                users.updateChildValues(data)
                self.showToast(message: "Profile Updated")
               // self.dismiss(animated: true, completion: nil)
                self.checkUserProfile()
                print("Successfully updated user info into Firebase database")
                
            })
            
            
            
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //dismiss the keyboard when view is tapped on
        emailTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        imagePicker.resignFirstResponder()
    }
    
    
    
}
