//
//  AnswerTableViewController.swift
//  bulletinboard
//
//  Created by bhavik on 12/12/18.
//  Copyright © 2018 bhavik. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseAuth
import FacebookCore
import FacebookLogin
import SwiftyJSON
import FirebaseDatabase
import FirebaseStorage

class AnswerTableViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var questionlabel: UILabel!
    @IBOutlet weak var tableViewBar: UITableView!
    
    var question : String?
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    var tableData = [Answers]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBarItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-undo-25"), style: .plain, target: self, action: #selector(cancelBtnPressed(sender:)))
      //  self.navigationBarItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBtnPressed(sender:)))
        self.navigationBarItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-plus-25"), style: .plain, target: self, action: #selector(addAnswer(sender:)))
//        self.navigationBarItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(addAnswer(sender:)))
         self.fetchCategoriesDatabase()
        self.tableViewBar.delegate = self
        self.tableViewBar.dataSource = self
       // self.tableView.tableHeaderView = question as UIView?
        // #warning Incomplete implementation, return the number of sections
      
    }
    override func viewWillAppear(_ animated: Bool) {
        questionlabel.text = question
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableData.count
    }
    
    @objc func cancelBtnPressed(sender: UIBarButtonItem){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func addAnswer(sender: UIBarButtonItem){
        print("inside add answer")
        self.performSegue(withIdentifier: "addAnswer", sender: self)
    }
    
 

    func fetchCategoriesDatabase() {
        var ref = Database.database().reference()
        
        print("inside fetchdatabase")
       
        if question != nil && question != "all" {
            self.tableData.removeAll()
            print("question ",question)
            ref.child("answers_db").queryOrdered(byChild: "question").queryStarting(atValue: self.question!).observe(.childAdded, with: {(snapshot) in
                let results = snapshot.value as? [String : Any]
                print("results")
                print(results)
                let question = results?["question"]
                var photourl = results?["photourl"]
                if question as? String == self.question{
                    let answer = results?["answer"]
                    print("question",question as Any)
                    let answers = Answers(answer: answer as! String,question: question as! String,photourl: photourl as! String )
                    self.tableData.append(answers as! Answers)
                    
                }
                self.tableViewBar.reloadData()
                
                
                
            })
        }
      
       
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.tableData[indexPath.row].answer
        cell.selectionStyle = .blue
        // Configure the cell...

        return cell
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ansDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAnswer"{
            print("addAnswer")
                let controller = (segue.destination as! AddAnswerViewController)
                print("inside searchActive")
                print("questionlabel",question!)
                controller.question = question!
                print(controller.question)
            }
        if segue.identifier == "ansDetail"
        {
          
            if let indexPath = tableViewBar.indexPathForSelectedRow{
            let controller = (segue.destination as! DetailAnswerViewController)
            controller.answer = tableData[indexPath.row]
            print("inside ans detail")
            }
        }
    }
    
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
