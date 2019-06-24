//
//  AddAnswerViewController.swift
//  bulletinboard
//
//  Created by bhavik on 13/12/18.
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

class AddAnswerViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var question: String?
    var finalImage : String? = ""
    var photoTextField: String?=""
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var btnPublish: UIButton!
    @IBOutlet weak var btnAddphoto: UIButton!
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var questionLbl: UILabel!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
     var profilePicture: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationBarItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBtnPressed(sender:)))
         self.navigationBarItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-undo-25"), style: .plain, target: self, action: #selector(cancelBtnPressed(sender:)))
        
        // Do any additional setup after loading the view.
    }
    @objc func cancelBtnPressed(sender: UIBarButtonItem){
        dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        print(self.question)
        self.questionLbl.text =  question
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnPhotoPressed(_ sender: UIButton) {
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
    
    @IBAction func btnPublishPressed(_ sender: UIButton) {
        if self.photoTextField == ""{
        let ansName = self.answerTextView.text!
        let question = self.questionLbl.text!
        let photourl = "No image upload"
        print("catName",ansName)
       
        print("question",question)
        let data = [
            "answer": ansName,
            "question": question,
            "photourl": photourl
            ]as [String:Any]
        print("data",data)
        let answer = Answers(answer: ansName,question: question, photourl: photourl)
        var ref = Database.database().reference()
        var answers = ref.child("answers_db")
        answers.childByAutoId().setValue(data)
        self.showToast(message: "Answer added")
        self.dismiss(animated: true, completion: nil)
        }
        else{
            self.saveAnswerProfiletoFireBase()
        }
    
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
    

    func saveAnswerProfiletoFireBase(){
        print("inside saveUserprofile")
        let fileName = UUID().uuidString
        guard let profileImageUploadData = UIImageJPEGRepresentation(self.profilePicture!, 0.3) else{return}
        Storage.storage().reference().child("answerImages").child(fileName).putData(profileImageUploadData, metadata: nil) { (metadata, err) in
            if let err = err {
                //                Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user with error: \(err.localizedDescription)", delay: 3);
                return
            }
            //      guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user.", delay: 3); return }
            Storage.storage().reference().child("answerImages").child(fileName).downloadURL(completion: { (url, err) in
                guard let photourl = url else { print("Failed to save profile pic")
                    return }
                
                print("Successfully uploaded profile image into Firebase storage with URL:", photourl)
            
                let data = ["answer": self.answerTextView.text,
                                        "question": self.questionLbl.text,
                                        "photourl": photourl.absoluteString] as [String : Any?]
                    let answer = Answers(answer: self.answerTextView.text!,question: self.questionLbl.text!, photourl: photourl.absoluteString)
                    var ref = Database.database().reference()
                    var answers = ref.child("answers_db")
                    answers.childByAutoId().setValue(data)
                    self.showToast(message: "Answer added")
                    self.dismiss(animated: true, completion: nil)
                    print("Successfully saved user info into Firebase database")
                  
                })
                
          
            
        }
        
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
