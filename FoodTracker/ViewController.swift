//
//  ViewController.swift
//  FoodTracker
//
//  Created by Tony Morales on 4/9/15.
//  Copyright (c) 2015 Tony Morales. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    
    let kAppID = "cb950b6e"
    let kAppKey = "dd076d38b7995caf618de2cf43419bdc"
    
    
    var searchController: UISearchController!

    var suggestedSearchFoods: [String] = []
    var filteredSuggestedSearchFoods: [String] = []
    
    var apiSearchForFoods: [(name: String, idValue: String)] = []
    
    var favoritedUSDAItems: [USDAItem] = []

    var filteredFavoritedUSDAItems: [USDAItem] = []
    
    var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
    
    var jsonResponse: NSDictionary!
    
    var dataController = DataController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.searchController = UISearchController(searchResultsController: nil)
        
        self.searchController.searchResultsUpdater = self
        
        self.searchController.dimsBackgroundDuringPresentation = false
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0)
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        
        self.searchController.searchBar.scopeButtonTitles = scopeButtonTitles
        self.searchController.searchBar.delegate = self
        
        self.definesPresentationContext = true
        
        
        self.suggestedSearchFoods = ["apple", "bacon", "bagel", "banana", "beer", "bread", "broccoli", "brussel sprouts", "burger", "cappuccino", "carrots", "cheese", "chicken nuggets", "chili", "chocolate chip cookies", "coffee", "donut", "graham cracker", "hot dog", "ice cream", "ketchup", "milk", "mountain dew", "nuts", "oatmeal", "orange juice", "peanut butter", "pizza", "pork belly", "potato", "pretzels", "rice", "salsa", "shrimp", "spaghetti", "wine"]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "usdaItemDidComplete:", name: kUSDAItemCompleted, object: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailVCSegue" {
            if sender != nil {
                var detailVC = segue.destinationViewController as DetailViewController
                detailVC.usdaItem = sender as? USDAItem
            }
        }
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // Mark - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0 {
            if self.searchController.active && self.searchController.searchBar.text != "" {
                return self.filteredSuggestedSearchFoods.count
            } else {
                return self.suggestedSearchFoods.count
            }
        } else if selectedScopeButtonIndex == 1 {
            return self.apiSearchForFoods.count
        } else {
            
            if self.searchController.active && self.searchController.searchBar.text != "" {
                return self.filteredFavoritedUSDAItems.count
            } else {
                return self.favoritedUSDAItems.count
            }
        }
        

        
        
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        var foodName: String
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0 {
            if self.searchController.active && self.searchController.searchBar.text != "" {
                foodName = filteredSuggestedSearchFoods[indexPath.row]
            } else {
                foodName = suggestedSearchFoods[indexPath.row]
            }
        } else if selectedScopeButtonIndex == 1 {
            foodName = apiSearchForFoods[indexPath.row].name
        } else {
            
            if self.searchController.active && self.searchController.searchBar.text != "" {
                foodName = self.filteredFavoritedUSDAItems[indexPath.row].name
            } else {
                foodName = self.favoritedUSDAItems[indexPath.row].name
            }
        }
        
        cell.textLabel?.text = foodName
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
        
    }
    
    
    // Mark - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0 {
            var searchFoodName: String
            
            if self.searchController.active && self.searchController.searchBar.text != "" {
                searchFoodName = filteredSuggestedSearchFoods[indexPath.row]
            } else {
                searchFoodName = suggestedSearchFoods[indexPath.row]
            }
            
            self.searchController.searchBar.selectedScopeButtonIndex = 1
            makeRequest(searchFoodName)
            
            
        } else if selectedScopeButtonIndex == 1 {
            self.performSegueWithIdentifier("toDetailVCSegue", sender: nil)
            let idValue = apiSearchForFoods[indexPath.row].idValue
            self.dataController.saveUSDAItemForId(idValue, json: self.jsonResponse)
            
        } else if selectedScopeButtonIndex == 2 {
            if self.searchController.active && self.searchController.searchBar.text != "" {
                let usdaItem = filteredFavoritedUSDAItems[indexPath.row]
                self.performSegueWithIdentifier("toDetailVCSegue", sender: usdaItem)
            } else {
                let usdaItem = favoritedUSDAItems[indexPath.row]
                self.performSegueWithIdentifier("toDetailVCSegue", sender: usdaItem)
            }
        }
        
    }
    
    // Mark - UISearchResultsUpdating

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        
        let searchString = self.searchController.searchBar.text
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        self.filterContentForSearch(searchString, scope: selectedScopeButtonIndex)
        self.tableView.reloadData()
        
        
    }
    
    func filterContentForSearch (searchText: String, scope: Int) {
        
        if scope == 0 {
            self.filteredSuggestedSearchFoods = self.suggestedSearchFoods.filter({ (food: String) -> Bool in
                var foodMatch = food.rangeOfString(searchText)
                return foodMatch != nil
            })
        } else if scope == 2 {
            self.filteredFavoritedUSDAItems = self.favoritedUSDAItems.filter({ (item: USDAItem) -> Bool in
                var stringMatch = item.name.rangeOfString(searchText)
                
                return stringMatch != nil
            })
        }
        
    }
    
    
    // Mark - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchController.searchBar.selectedScopeButtonIndex = 1
        makeRequest(searchBar.text)
    }
    
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        if selectedScope == 2 {
            requestFavoritedUSDAItems()
        }
        
        self.tableView.reloadData()
    }
    
    func makeRequest (searchString: String) {
 
        
        // How to make an HTTP Get Request
        
        
//        let url = NSURL(string: "https://api.nutritionix.com/v1_1/search/\(searchString)?results=0%3A20&cal_min=0&cal_max=50000&fields=item_name%2Cbrand_name%2Citem_id%2Cbrand_id&appId=\(kAppID)&appKey=\(kAppKey)")
//        
//        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
//            
//            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
//            println(stringData)
//            println(response)
//            
//        })
//        task.resume()

    
        var request = NSMutableURLRequest(URL: NSURL(string: "https://api.nutritionix.com/v1_1/search/")!)
        
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var params = [
            "appId": kAppID,
            "appKey": kAppKey,
            "fields": ["item_name", "brand_name", "keywords", "usda_fields"],
            "limit": "50",
            "query": searchString,
            "filters": ["exists": ["usda_fields": true]]
        ]
        
        var error: NSError?
        
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            
//            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
//            println(stringData)
            var conversionError: NSError?
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &conversionError) as? NSDictionary
//            println(jsonDictionary)
            
            if conversionError != nil {
                println(conversionError!.localizedDescription)
                let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error in Parsing \(error)")
            } else {
                
                if jsonDictionary != nil {
                    self.jsonResponse = jsonDictionary!
                    
                    self.apiSearchForFoods = DataController.jsonAsUSDAIDAndNameSearchResults(jsonDictionary!)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                    
                } else {
                    let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error Could Not Parse JSON \(errorString)")
                }
                
            }
            
        })
        
        task.resume()
        
        
    }
    
    
    // Mark - Setup CoreDate
    
    func requestFavoritedUSDAItems() {
        let fetchRequest = NSFetchRequest(entityName: "USDAItem")
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let managedObjectContext = appDelegate.managedObjectContext
        self.favoritedUSDAItems = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as [USDAItem]
        
        
    }
    
    // Mark - NSNotificationCenter
    
    func usdaItemDidComplete(notification: NSNotification) {
        
        println("usdaItemDidComplete in ViewController")
        requestFavoritedUSDAItems()
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 2 {
            self.tableView.reloadData()
        }
    }
}