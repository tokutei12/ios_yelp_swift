//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import ChameleonFramework

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationItem!
    var businesses: [Business]!
    var searchBar: UISearchBar!
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    var currentSearch: String?
    var currentCategories: [String]?
    var currentDeals: Bool?
    var currentDistance: Int?
    var currentSort: YelpSortMode?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120

        searchBar = UISearchBar()
        navBar.titleView = searchBar
        searchBar.delegate = self
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets

        Business.searchWithTerm(term: "Restaurants", limit: 20, offset: 0, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        })        
    }
    
    @IBAction func onTapScreen(_ sender: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }
    
    func loadMoreData() {
        print("load more data")
        Business.searchWithTerm(term: currentSearch ?? "Restaurants", limit: 20, offset: self.businesses.count, sort: currentSort ?? nil, categories: currentCategories ?? nil, deals: currentDeals ?? nil, distance: currentDistance ?? nil, completion: {(businesses: [Business]?, error: Error?) -> Void in
            print(businesses!)
            let extendedBusinesses = self.businesses + businesses!
            self.businesses = extendedBusinesses
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
            self.tableView.reloadData()
        })
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height

            // Update position of loadingMoreView, and start loading indicator
            let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
            loadingMoreView?.frame = frame
            loadingMoreView!.startAnimating()
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                loadMoreData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        currentSearch = searchBar.text
        Business.searchWithTerm(term: currentSearch ?? "Restaurants", limit: 20, offset: 0, sort: currentSort ?? nil, categories: currentCategories ?? nil, deals: currentDeals ?? nil, distance: currentDistance ?? nil, completion: {(businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        })
        searchBar.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
    }
    
    func filtersViewController(filterViewController: FiltersViewController, didUpdateFilters filters: [String: AnyObject]) {

        currentSearch = searchBar?.text as String!
        currentCategories = filters["categories"] as? [String]
        currentDeals = filters["deals"] as? Bool
        currentDistance = filters["distance"] as? Int
        currentSort = filters["sort"] as? YelpSortMode

        Business.searchWithTerm(term: currentSearch!, limit: 20, offset: 0, sort: currentSort, categories: currentCategories, deals: currentDeals, distance: currentDistance, completion: {(businesses: [Business]?, error: Error?) -> Void in
                self.businesses = businesses
                self.tableView.reloadData()
            })
    }
    
}
