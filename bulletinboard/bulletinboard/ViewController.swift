//
//  ViewController.swift
//  bulletinboard
//
//  Created by bhavik on 02/12/18.
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
import MessageUI

class ViewController: UIViewController{
    
   
    var name: String?
    var email: String?
    var profilePicture: UIImage?
    @IBOutlet weak var faceBookLoginButton: UIButton!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var signInSelector: UISegmentedControl!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    var isSignIn : Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    override func viewDidAppear(_ animated: Bool) {
       
        
        Auth.auth().addStateDidChangeListener{auth, user in
            if let user = user{
                if user.isEmailVerified{
                self.performSegue(withIdentifier: "HomePage", sender: self)
                }
                else if !user.isEmailVerified{
                    Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                }
            }
            else{

            }

        }
    }
    @IBAction func signInButtonClicked(_ sender: UIButton) {
        
        
        //Do some validation on email and password
        if let email = emailTextField.text,let pass = passwordTextField.text{
            if self.isValidEmail(testStr: emailTextField.text!){
            //Check if its sign in or register
            if isSignIn{
                //Sign in with FireBase
                print(email)
                print(pass)
                Auth.auth().signIn(withEmail: email, password: pass, completion: {(user,error) in
                    //Check that user isn't nill
                    if let u = user{
                       // self.performSegue(withIdentifier: "HomePage", sender: self)
                        //user is found
                        let dictionaryValues = ["name": email,
                                                "email": email,
                                                "profileImageUrl": "No Image Found"] as [String : Any?]
                        guard let uid = Auth.auth().currentUser?.uid else {return};
                        if let user = Auth.auth().currentUser {
                            if !user.isEmailVerified{
                                let alertVC = UIAlertController(title: "Error", message: "Sorry. Your email address has not yet been verified.", preferredStyle: .alert)
                                let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                                    (_) in
                                    user.sendEmailVerification(completion: nil)
                                }
                                let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                                
                                alertVC.addAction(alertActionOkay)
                                alertVC.addAction(alertActionCancel)
                                self.present(alertVC, animated: true, completion: nil)
                            } else {
                                print ("Email verified. Signing in...")
                                let values = [uid : dictionaryValues]
                                print("abc")
                                Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                                    if let err = err {
                                        print("Failed to save user")
                                        return
                                    }
                                    print("Successfully saved user info into Firebase database")
                                    self.performSegue(withIdentifier: "HomePage", sender: self)
                                    print("Successfully saved profile.")
                                })

                            }
                        }
                        
                    }
                    else{
                        //Error, check Error and show message
                        print("User Not Registerd")
                        self.showToast(message: "User Not Registered")
                    }
                })
                // ...
            }
                
            else{
                //Register with FireBase
                Auth.auth().createUser(withEmail: email, password: pass, completion:  { (user, error) in
                    //check user isn't nill
                    if let u = user{
                        
                        //user is found go to home screen
                       // self.performSegue(withIdentifier: "HomePage", sender: self)
                        
                        let dictionaryValues = ["name": email,
                                                "email": email,
                                                "profileImageUrl": "No Image Found"] as [String : Any?]
                        guard let uid = Auth.auth().currentUser?.uid else {return};
                        let values = [uid : dictionaryValues]
                        print("abc")
                        Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                            if let err = err {
                                print("Failed to save user")
                                return
                            }
                            print("Successfully saved user info into Firebase database")
                            self.showToast(message: "Please sign in!")
                            //self.performSegue(withIdentifier: "HomePage", sender: self)
                            print("Successfully saved profile.")
                        })
                    }
                    else{

                        let alert = UIAlertController(title: "Cant Register", message: "User Already Exist. Please Sign in" , preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        //Error, check error and show message
                    }
                    
                    if error == nil{
                        Auth.auth().currentUser?.sendEmailVerification(completion: { (errs) in
                            if errs == nil{
                                print("inside register")
                                if (Auth.auth().currentUser?.isEmailVerified)!{
                                self.performSegue(withIdentifier: "HomePage", sender: self)
                                }
                            }
                            else{
                                self.showToast(message: "User not verified")
                            }
                        })
                    }
                })
            }
        }
            
            else{
                self.showToast(message: "Invalid Email.")
        }
       
        }
    
      
    }
    @IBAction func SignInSelectorChanged(_ sender: UISegmentedControl) {
      
        //Flip the Boolean
        isSignIn = !isSignIn
        //Check the bool and set the button and labels
        if isSignIn{
//
            signInLabel.text = "Sign In"
            signInButton.setTitle("Sign In", for: UIControlState.normal)
        }
        else{
           
            signInLabel.text = "Register"
            signInButton.setTitle("Register", for: UIControlState.normal)
        }
  
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //dismiss the keyboard when view is tapped on
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

    }
    
    @IBAction func fbLoginButtonPressed(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile,.email], viewController: self){ (LoginResult) in
            switch LoginResult{
            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
                self.signInToFireBase()
                self.fetchUserProfile()
                  self.performSegue(withIdentifier: "HomePage", sender: self)
            case .failed(let err):
                print(err)
            case .cancelled:
                print("Cancelled")
                
            }
        }
    }
    
    
    func signInToFireBase(){
       guard let authenticationToken = AccessToken.current?.authenticationToken else{return}
       let credential = FacebookAuthProvider.credential(withAccessToken: authenticationToken)
        Auth.auth().signIn(with: credential){
            (user, err) in
            if let err = err{
                print(err)
                return
            }
          //  self.performSegue(withIdentifier: "HomePage", sender: self)
            print("Successfully authenticated through Facebook.")
        }
    }
    
    func fetchUserProfile(){
        print("inside fetchuserprofile")
        let graphRequestCOnnection = GraphRequestConnection()
        let graphRequest = GraphRequest(graphPath:"me", parameters:["fields": "id,email,name,picture.type(large)"],accessToken: AccessToken.current,httpMethod: .GET,apiVersion: .defaultVersion)
        graphRequestCOnnection.add(graphRequest){(httpResponse, result) in
            print("inside switch")
            switch result{
            case .success(response: let response):
                print("inside switch success")
                guard let responseDictionary = response.dictionaryValue else {return}
                let json = JSON(responseDictionary)
                self.name = json["name"].string
                self.email = json["email"].string
                print("name",self.name)
                print("json")
                print(json.dictionary?.keys)
                guard let profilePictureUrl = json["picture"]["data"]["url"].string else{return}
                print("profiile picture",profilePictureUrl)
                guard let url = URL(string: profilePictureUrl) else{return}
                URLSession.shared.dataTask(with: url,completionHandler:{(data, response, err) in
                    if let err = err{
                        print(err)
                        return
                    }
                    print("before data swicth")
                    guard let data = data else{return}
                    self.profilePicture = UIImage(data: data)
                    self.saveUserProfiletoFireBase()
                }).resume()
                break
            case .failed(let err):
                print(err)
                break
            }
            
        }
        graphRequestCOnnection.start()
    }

    func saveUserProfiletoFireBase(){
        print("inside saveUserprofile")
        let fileName = UUID().uuidString
        guard let profileImageUploadData = UIImageJPEGRepresentation(self.profilePicture!, 0.3) else{return}
        guard let uid = Auth.auth().currentUser?.uid else {return};
        Storage.storage().reference().child("profileImages").child(fileName).putData(profileImageUploadData, metadata: nil) { (metadata, err) in
        if let err = err {
//                Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user with error: \(err.localizedDescription)", delay: 3);
                return
            }
            //      guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user.", delay: 3); return }
            Storage.storage().reference().child("profileImages").child(fileName).downloadURL(completion: { (url, err) in
                guard let profileImageUrl = url else { print("Failed to save profile pic")
                    return }
                
                print("Successfully uploaded profile image into Firebase storage with URL:", profileImageUrl)
                
                let dictionaryValues = ["name": self.name,
                                        "email": self.email,
                                        "profileImageUrl": profileImageUrl.absoluteString] as [String : Any?]
                let values = [uid : dictionaryValues]
                print("abc")
                Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if let err = err {
                        print("Failed to save user")
                        return
                    }
                    print("Successfully saved user info into Firebase database")
                    self.performSegue(withIdentifier: "HomePage", sender: self)
                    print("Successfully saved profile.")
                })
                
            })
            
        }
        
    }
    
    
//    func configureEmailControler()-> MFMailComposeViewController{
//        let mailComposerVC = MFMailComposeViewController()
//        mailComposerVC.mailComposeDelegate = self
//        mailComposerVC.setToRecipients(["bshah267@gmail.com"])
//        mailComposerVC.setSubject("test")
//        mailComposerVC.setMessageBody("How r you", isHTML: false)
//        return mailComposerVC
//    }
//
//    func showMailError() {
//        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
//        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
//        sendMailErrorAlert.addAction(dismiss)
//        self.present(sendMailErrorAlert, animated: true, completion: nil)
//    }
//
//    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//        controller.dismiss(animated: true, completion: nil)
//    }
//
}

extension UIViewController{
    
    func isValidEmail(testStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}
}
