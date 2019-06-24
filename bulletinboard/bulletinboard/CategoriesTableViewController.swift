//
//  CategoriesTableViewController.swift
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

class CategoriesTableViewController:
UITableViewController,UINavigationControllerDelegate,UISearchResultsUpdating,UITabBarControllerDelegate{
    
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    var tableData = [Category]()
    var filtered:[Category] = []
    var searchActive : Bool = false
    func updateSearchResults(for searchController: UISearchController) {
        
        self.filterContentForSearch(searchString: searchController.searchBar.text!)
    }
    func filterContentForSearch(searchString : String){
        // filtered.removeAll()
        print("inside searfchcc")
        self.filtered=self.tableData.filter(){
            nil != $0.name?.lowercased().range(of: searchString.lowercased())
            
        }
        self.tableView.reloadData()
    }
    
    
  
  
   let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
       // searchBar.delegate = self
        self.fetchCategoriesDatabase()
      //  self.setupNavbar()
        navigationBarItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-plus-25"), style: .plain, target: self, action: #selector(add_Category(sender:)))
        navigationBarItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action:#selector(searchCategory(sender:)))
        ///navigationBarItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(add_Category(sender:)))
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
      
       
        //tableView.tableHeaderView = self.navigationBarItem
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func setupNavbar(){
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation=false
        searchController.searchResultsUpdater = self as! UISearchResultsUpdating
        searchController.isActive = true
        //searchController.searchBar.prompt = "Search Category"
        searchController.searchBar.becomeFirstResponder()
        definesPresentationContext=true
    }
    
    override func viewWillAppear(_ animated: Bool) {
       // self.fetchCategoriesDatabase()
        self.tableView.reloadData()
       
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
        if searchController.isActive && searchController.searchBar.text != "" {
            return self.filtered.count
        }
        
        return self.tableData.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
     //   guard fetchElements.last! != knownOldestElement else{return}
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        print("inside tableviewww")
        	
        if searchController.isActive && searchController.searchBar.text != ""{
            print("inside ")
            cell.textLabel?.text = self.filtered[indexPath.row].name
            cell.selectionStyle = .blue
        }
        else{
            for c in self.tableData{
            print("name is ",c.name)
            }
        print(self.tableData)
        cell.textLabel?.text = self.tableData[indexPath.row].name
        cell.selectionStyle = .blue
        // Configure the cell...
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var secondTab = tabBarController?.viewControllers![0] as! UINavigationController
        var tabs = secondTab.topViewController as! HomeViewController
        tabs.categoryName = tableData[indexPath.row].name!
        print("hope to see",tabs.categoryName)
        print("cccccccc",tabs.categoryName!)
        navigationController?.tabBarController?.selectedIndex = 0
//         tabs.categoryName = tableData[indexPath.row].name!
        
      ///  performSegue(withIdentifier: "categorySearch", sender: self)
        
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
            
            self.tableView.reloadData()

            })
                    // print(self.tableData)
        //   print("name - ", categories.name)
        
    }
    @objc func searchCategory(sender: UIBarButtonItem){
        print("inside searchCategory")
        self.setupNavbar()
        //self.searchBarControl.isHidden = false
        
    }
    @objc func add_Category(sender: UIBarButtonItem){
        print("inside addcategory")
//        navigationController?.pushViewController(AddCategoryViewController(), animated: true)
        self.performSegue(withIdentifier: "add", sender: self)
        
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("inside prepare")
//        if let child = segue.destination as? ViewController {
//            child.tabDelegate = self
//        }
//        if segue.identifier == "categorySearch"{
//            print("showDetail")
//            print(searchActive)
//            if let indexPath = tableView.indexPathForSelectedRow {
//                print(indexPath)
    //                print(searchActive)
//            if searchController.isActive && searchController.searchBar.text != ""{
//                    let controller = (segue.destination as! UITableViewController)
//                    print("inside searchActive")
//                    controller.categoryName = filtered[indexPath.row].name
//                controller.navigationBarItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action:#selector(controller.searchQuestion(sender:)))
//                controller.navigationBarItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(controller.addQuestion(sender:)))
//                
//                }
//                else{
//                    let controller = (segue.destination as! UITableViewController) as! HomeViewController
//                    controller.categoryName = tableData[indexPath.row].name
//                controller.navigationBarItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action:#selector(controller.searchQuestion(sender:)))
//                controller.navigationBarItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(controller.addQuestion(sender:)))
//                   }
//            }
//        }
//        
//    }

    
    
    
}

extension CategoriesTableViewController : UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("inside search bar textchange")
        filtered.removeAll()
        filtered = tableData.filter({ $0.name!.lowercased().prefix(searchText.count) == searchText.lowercased()})
        
        for f in filtered{
            print(f.name)
           
        }
        
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.text = ""
        self.resignFirstResponder()
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        print("inside beginediting")
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        print("inside endediting")
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("inside search")
        self.resignFirstResponder()
        searchActive = false;
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

