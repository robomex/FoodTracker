//
//  ViewController.swift
//  FoodTracker
//
//  Created by Tony Morales on 4/9/15.
//  Copyright (c) 2015 Tony Morales. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    
    let kAppID = "cb950b6e"
    let kAppKey = "dd076d38b7995caf618de2cf43419bdc"
    
    
    var searchController: UISearchController!

    var suggestedSearchFoods: [String] = []
    var filteredSuggestedSearchFoods: [String] = []
    
    var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
    
    
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // Mark - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.searchController.active {
            return self.filteredSuggestedSearchFoods.count
        } else {
            return self.suggestedSearchFoods.count
        }
        
        
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        var foodName: String
        
        if self.searchController.active {
            foodName = filteredSuggestedSearchFoods[indexPath.row]
        } else {
            foodName = suggestedSearchFoods[indexPath.row]
        }
        
        cell.textLabel?.text = foodName
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
        
    }
    
    
    
    // Mark - UISearchResultsUpdating

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        
        let searchString = self.searchController.searchBar.text
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        self.filterContentForSearch(searchString, scope: selectedScopeButtonIndex)
        self.tableView.reloadData()
        
        
    }
    
    func filterContentForSearch (searchText: String, scope: Int) {
        self.filteredSuggestedSearchFoods = self.suggestedSearchFoods.filter({ (food: String) -> Bool in
            var foodMatch = food.rangeOfString(searchText)
            return foodMatch != nil
        })
    }
    
    
    // Mark - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        makeRequest(searchBar.text)
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

    
    }
    
    
    
    
    
}

