//
//  AddCategoryViewController.swift
//  bulletinboard
//
//  Created by bhavik on 11/12/18.
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


extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 8.0, delay: 0, options:.curveLinear, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}


class AddCategoryViewController: UIViewController {
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    @IBOutlet weak var categoryDescriptionTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var questionTextField: UITextView!
    @IBOutlet weak var categoryNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let backbutton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-undo-25"), style: .plain, target: self, action: #selector(backButtonPressed(sender:)))
//        let backbutton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backButtonPressed(sender:)))
        self.navigationBarItem.leftBarButtonItem = backbutton
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let catName = self.categoryNameTextField.text!
        let catDescription = self.categoryDescriptionTextField.text!
        let question = self.questionTextField.text!
        print("catName",catName)
        print("catDescription",catDescription)
        print("question",question)
        let data = [
            "name": catName,
            "description": catDescription
            ]as [String:Any]
        print("data",data)
        let category = Category(name: catName, description: catDescription)
        var ref = Database.database().reference()
        var categories = ref.child("categories_db")
        categories.childByAutoId().setValue(data)
        
        let question_data = ["question": question, "categories":catName as String?] as [String:Any]
      
        var questions = ref.child("qa_db")
        questions.childByAutoId().setValue(question_data)
        self.showToast(message: "Category and question added")
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func backButtonPressed(sender: UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //dismiss the keyboard when view is tapped on
        categoryDescriptionTextField.resignFirstResponder()
        categoryDescriptionTextField.resignFirstResponder()
        questionTextField.resignFirstResponder()
    }
}
