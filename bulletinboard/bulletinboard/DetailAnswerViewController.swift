//
//  DetailAnswerViewController.swift
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

class DetailAnswerViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    var answer: Answers?
    override func viewDidLoad() {
        super.viewDidLoad()
        print("from tableview")
        print("answer",answer)
        self.imageView.isHidden = true
        readAnswer()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func readAnswer(){
        self.textView.text = answer?.answer
        if answer?.photourl != "No image upload"{
            print("abcdefghi")
            print(answer?.photourl)
            self.imageView.isHidden = false
            let storageRef = Storage.storage().reference(forURL: answer!.photourl!)
            // Download the data, assuming a max size of 1MB (you can change this as necessary)
            storageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) -> Void in
                // Create a UIImage, add it to the array
                guard let pfData = data
                    else{
                        self.imageView.image = UIImage(named: "whatsapp-dp-icon-4")
                        return
                }
                self.imageView.image = UIImage(data: pfData)
            }
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
