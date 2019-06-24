//
//  AddQuestionViewController.swift
//  bulletinboard
//
//  Created by bhavik on 12/12/18.
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




class AddQuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var isTableVisible = false
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var tblDropDown: UITableView!
    @IBOutlet weak var btncategory: UIButton!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var questionTextView: UITextView!
    var tableData = [Category]()
    var city : String = ""
    @IBOutlet weak var tbllDropDownHC: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchCategoriesDatabase()
        tblDropDown.delegate = self
          tbllDropDownHC.constant = 0
        tblDropDown.dataSource = self
         let backbutton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-undo-25"), style: .plain, target: self, action: #selector(backButtonPressed(sender:)))
//        let backbutton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backButtonPressed(sender:)))
        self.navigationBarItem.leftBarButtonItem = backbutton
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func publishButtonPressed(_ sender: UIButton) {
        let question = self.questionTextView.text!
       
        print("question",question)

          var ref = Database.database().reference()
        var categoryName = btncategory.title(for: .normal)
        let question_data = ["question": question as String?,
                             "categories" :categoryName as String?,
                             "city": city] as [String:Any]
        
        var questions = ref.child("qa_db")
        questions.childByAutoId().setValue(question_data)
        self.showToast(message: "question added under category")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //dismiss the keyboard when view is tapped on
        questionTextView.resignFirstResponder()
       
    }
    @objc func backButtonPressed(sender: UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchCategoriesDatabase() {
        var ref = Database.database().reference()
        print("inside fetchdatabase")
        ref.child("categories_db").observe(.childAdded, with: { (snapshot) in
            let results = snapshot.value as? [String : Any]
            print("results",results)
            let name = results?["name"]
            let description = results?["description"]
            let categories = Category(name: name as! String, description: description as! String )
            
            self.tableData.append(categories)
            
            self.tblDropDown.reloadData()
            
        })
        // print(self.tableData)
        //   print("name - ", categories.name)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "categories")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "categories")
        }
        print(self.tableData)
        cell?.textLabel?.text = self.tableData[indexPath.row].name
//        cell?.textLabel?.text = "\(indexPath.row + 1)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        btncategory.setTitle(self.tableData[indexPath.row].name, for: .normal)
        UIView.animate(withDuration: 0.5) {
           
            self.isTableVisible = false
            self.view.layoutIfNeeded()
        }
        
    }

    @IBAction func categoryBtnPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            if self.isTableVisible == false {
                self.isTableVisible = true
                self.tbllDropDownHC.constant = 44.0 * 3.0
            } else {
                self.tbllDropDownHC.constant = 0
                self.isTableVisible = false
            }
            self.view.layoutIfNeeded()
        }
    }
    
}
