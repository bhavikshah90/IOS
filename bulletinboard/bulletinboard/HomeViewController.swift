//
//  HomeViewController.swift
//  bulletinboard
//
//  Created by bhavik on 02/12/18.
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
import MapKit
import UserNotifications
import MessageUI
//import AudioToolBox
import AVFoundation

class HomeViewController: UITableViewController, CLLocationManagerDelegate,UISearchResultsUpdating,MFMailComposeViewControllerDelegate{
    var categoryName :String?=""
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    let locationManager: CLLocationManager = CLLocationManager()
    var tableData = [Questions]()
    var filtered:[Questions] = []
    var baseTableData:[Questions]=[]
    var city: String = ""
    var country: String = ""
    var state: String = ""
    var zip: String = ""
    let searchController = UISearchController(searchResultsController: nil)
    var searchActive : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        print("caterrrrr",categoryName)
     //   self.fetchCategoriesDatabase()
        locationManager.delegate = self
     //   locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
     //   locationManager.stopUpdatingLocation()
        let emailButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-send-email-25"), style: .plain, target: self, action: #selector(emailPressed(sender:)))
        let addButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-plus-25"), style: .plain, target: self, action: #selector(addQuestion(sender:)))
        let locButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-marker-25"), style: .plain, target: self, action: #selector(updateLocationAction(sender:)))
        let chatButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-collaboration-filled-25"), style: .plain, target: self, action: #selector(chatAction(sender:)))
        let clearButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-clear-filters-25"), style: .plain, target: self, action: #selector(clearAction(sender:)))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action:#selector(searchQuestion(sender:)))
     //   let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(addQuestion(sender:)))
       // let locButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(updateLocationAction(sender:)))
//        let chatButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(chatAction(sender:)))
//        let clearButton = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(clearAction(sender:)))
        //let locbutton = UIBarButtonItem(image: #imageLiteral(resourceName: "location") , style: .plain, target: self, action: #selector(updateLocationAction(sender:)))
       
//        locbutton.colackgroundColor = UIColor(red: 0, green: 118/255, blue: 254/255, alpha: 1)
        self.navigationBarItem.rightBarButtonItems = [locButton, chatButton, addButton]
        self.navigationBarItem.leftBarButtonItems = [searchButton,clearButton,emailButton]
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        print("inside viewwil appear")
        if  categoryName != "" {
            print("notto worry")
            fetchQuestion()
        }
//        if categoryName == nil{
//            categoryName = "all"
//        }
        print("cate",categoryName)
        
    }
    
    @objc func emailPressed(sender:UIBarButtonItem){
        print("inside email")
        let mailComposeViewController = self.configureEmailControler()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showMailError()
        }
    }

    @objc func chatAction(sender:UIBarButtonItem){
        performSegue(withIdentifier: "chatSeague", sender: self)
    }
    @objc func clearAction(sender:UIBarButtonItem){
        categoryName = ""
        fetchQuestion()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location update")
        let location = locations[0]
        print("first")
//        self.fetchCategoriesDatabase()
        // self.fetchQuestion()
//        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01,0.01)
//        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
//        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        print(location.altitude)
        print(location.speed)
       CLGeocoder().reverseGeocodeLocation(location){(placemark,error) in
            if error != nil{
                print("here is an error")
            }
            else{
                if let place = placemark?[0]
                  
                {
                    if let locationName = place.location {
                        print(locationName)
                    }
                    // Street address
                    if let street = place.thoroughfare {
                        print(street)
                    }
                    // City
                    if let city = place.subAdministrativeArea {
                        print(city)
                        self.city = city
                        self.fetchQuestion()
                        self.tableView.reloadData()
                        
                    }
                    //State
                    if let state = place.administrativeArea {
                        print(state)
                        self.state = state
                    }
                    // Zip code
                    if let zip = place.isoCountryCode {
                        print(zip)
                        self.zip = zip
                    }
                    // Country
                    if let country = place.country {
                        print(country)
                        self.country = country
                    }
                  }
            }
        }
        locationManager.stopUpdatingLocation()
        let data = [
            "country": country,
            "state": state,
            "city": city,
            "zip": zip
            ]as [String:Any]
        print("data",data)
        var ref = Database.database().reference()
        var location_db = ref.child("location_db")
        location_db.childByAutoId().setValue(data)
        self.showToast(message: "Location updated in location database")
        print("comestill here")
        
   //     self.fetchQuestion()
    }
//
   @objc func updateLocationAction(sender: UIBarButtonItem) {
        print("inside location")
        //locationManager.requestLocation()
        let alert = UIAlertController(title: "Update Location", message: "Enter a city", preferredStyle: .alert)
        alert.addTextField { (textField) in
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
        let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
        print("Text field: \(textField?.text)")
        self.city = (textField?.text)!
        print(self.city)
           // self.fetchCategoriesDatabase()
            self.fetchQuestion()
//            self.tableView.reloadData()
    }))
    self.present(alert, animated: true, completion: nil)
    self.fetchQuestion()
    self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    func setupNavbar(){
       
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation=false
        searchController.searchResultsUpdater = self as! UISearchResultsUpdating
        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
        definesPresentationContext=true
    }
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "searchAns", sender: self)
        //self.navigationController?.pushViewController(AnswerTableViewController.self as! UIViewController, animated: true)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
     
        if searchController.isActive && searchController.searchBar.text != ""{
            print("inside ")
            cell.textLabel?.text = self.filtered[indexPath.row].question
            cell.selectionStyle = .blue
        }
        else{
        print(self.tableData)
        for c in self.tableData{
            print("name is ",c.question)
        }
        cell.textLabel?.text = self.tableData[indexPath.row].question
        cell.selectionStyle = .blue
        // Configure the cell...
        }
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.filterContentForSearch(searchString: searchController.searchBar.text!)
    }
    
    func filterContentForSearch(searchString : String){
       // filtered.removeAll()
        print("inside searfchcc")
        self.filtered=self.tableData.filter(){
            nil != $0.question?.lowercased().range(of: searchString.lowercased())
            
        }
          self.tableView.reloadData()
}
    func fetchCategoriesDatabase() {
        print("city",city)
          print("inside fetchdatabase")
          self.tableData.removeAll()
          var ref = Database.database().reference()
          ref.child("qa_db").observe(.childAdded, with: { (snapshot) in
            let results = snapshot.value as? [String : Any]
            print("results")
            print(results)
            let question = results?["question"]
            let category = results?["categories"]
            let city = results?["city"]
            print("question",question)
            let questions = Questions(question: question as! String,category: category as! String,city: city as! String )
            self.tableData.append(questions as! Questions)
            self.tableView.reloadData()
        })
        
    }

    func fetchQuestion(){
        print("results of fetch question")
        self.tableData.removeAll()
        self.showToast(message: "Showing questions based on your Location")
        var ref = Database.database().reference()
        ref.child("qa_db").observe(.childAdded, with: { (snapshot) in
            let results = snapshot.value as? [String : Any]
            print("results")
            print(results)
            let question = results?["question"]
            let category = results?["categories"]
            let city = results?["city"]
            print("question",question)
            if self.categoryName != ""{
                print(self.categoryName)
                if self.categoryName == category as! String && self.city == city as! String{
                    print("Does it come insideee")
                    let questions = Questions(question: question as! String,category: category as! String,city: city as! String )
                    self.tableData.append(questions as! Questions)
                    self.tableView.reloadData()
                
                }
            }
                else{
                    if self.city == city as! String {
                    let questions = Questions(question: question as! String,category: category as! String,city: city as! String )
                    self.tableData.append(questions as! Questions)
                    self.tableView.reloadData()
                }
                }
         
        })
        

        self.tableView.reloadData()
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "cell"{
                    print("showDetail")
                    print(searchActive)
                    if let indexPath = tableView.indexPathForSelectedRow {
                        print(indexPath)
                        print(searchActive)
                        let controller = (segue.destination as! AnswerTableViewController)
                        print("inside searchActive")
                        controller.question = self.tableData[indexPath.row].question
                        //controller.navigationBarItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(controller.cancelBtnPressed(sender:)))
                      //  controller.navigationBarItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(controller.addQuestion(sender:)))
                    }
                    
    }
        if segue.identifier == "addQuestion"{
            let controller = (segue.destination as! AddQuestionViewController)
            controller.city = self.city
            print("addviraksdlksadla",controller.city)
            
            
        }
        if segue.identifier == "chatSeague"{
            print("chat inside")
            let controller = (segue.destination as! MessagesTableViewController)
        }
    }
    
        @objc func searchQuestion(sender: UIBarButtonItem){
        print("inside search question")
        self.setupNavbar()
    }
    
    @objc func addQuestion(sender: UIBarButtonItem){
        print("inside add question")
        performSegue(withIdentifier: "addQuestion", sender: self)
    }
func configureEmailControler()-> MFMailComposeViewController{
    let mailComposerVC = MFMailComposeViewController()
    mailComposerVC.mailComposeDelegate = self
    mailComposerVC.setToRecipients(["bshah267@gmail.com"])
    mailComposerVC.setSubject("test")
    mailComposerVC.setMessageBody("How r you", isHTML: false)
    return mailComposerVC
}

func showMailError() {
    let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
    let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
    sendMailErrorAlert.addAction(dismiss)
    self.present(sendMailErrorAlert, animated: true, completion: nil)
}

func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true, completion: nil)
}

   
    
}
extension HomeViewController : UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("inside search bar textchange")
        filtered.removeAll()
        filtered = tableData.filter({ $0.question!.lowercased().prefix(searchText.count) == searchText.lowercased()})
        
        for f in filtered{
            print(f.question)
            
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
        searchBar.isHidden = true
        searchActive = false;
    }
    
    
}
