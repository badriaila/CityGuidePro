//
//  ExitsViewController.swift
//  CityGuidePro
//
//  Updated by AJ
//  ExitsViewController

import UIKit

class ExitsViewController: UITableViewController, UISearchControllerDelegate {
    
    var searchResultsController = UISearchController(searchResultsController: nil)
    var currentNode : Int = -1
    
    func setCurrentNode(node : Int){
        currentNode = node
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        searchResultsController.delegate = self
        searchResultsController.searchResultsUpdater = self
        self.view.backgroundColor = UIColor(named: "viewFlipsideBackgroundColor")
        
        // Place the search bar in the navigation bar
        navigationItem.searchController = searchResultsController
        
        // Make the search bar always visible
        navigationItem.hidesSearchBarWhenScrolling = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationItem.title = "Emergency Exits"
    }
    
    var isSearchBarEmtpy : Bool{
        return searchResultsController.searchBar.text?.isEmpty ?? true
    }
    var isFiltereing : Bool {
        return searchResultsController.isActive && !isSearchBarEmtpy
    }
    
    var locations : [String] = []
    func getLocations(values : [String]){
        if !locations.isEmpty{
            locations.removeAll()
        }
        for i in values{
            if !locations.contains(i){
                locations.append(i)
                
                // gets only the locations containing the word "Stairs"
                locations = locations.filter{ $0.contains("Stairs") }
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    var Filteredlocations : [String] = []
    func filterContents(values : [String] , text : String){
        Filteredlocations = values.filter({ values in
            return values.lowercased().contains(text.lowercased())
        })
        tableView.reloadData()
//        print(Filteredlocations)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // After selecting a suggested destination
        let selectedDes = tableView.cellForRow(at: indexPath)?.textLabel?.text
        for i in dArray{
            if i["locname"] as? String == selectedDes{
                let desNode = Int(truncating: i["node"] as! NSNumber)
                shortestPath = pathFinder(current: currentNode, destination: desNode)
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltereing{
            


            return Filteredlocations.count
        }
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if isFiltereing{
            cell.textLabel?.text = Filteredlocations[indexPath.row]
        }
        else{
            cell.textLabel?.text = locations[indexPath.row]
        }
        return cell
    }
}

extension ExitsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        if searchText!.isEmpty{
            getLocations(values: destinations)
        }
        else{
            filterContents(values: destinations, text: searchText!)
        }
    }
}
