//
//  AddLocationController.swift
//  FiTRi9i
//
//  Created by Radhi Mighri on 09/09/20.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import MapKit

private var reuseIdentifier = "Cell"

//because we gonna passed data from a controller to another controller we've to use a protocol
protocol AddLocationProtocolDelegate: class {
    func updatLocation(locationString: String, type: LocationType)
}


class AddLocationController: UITableViewController {
    
    //MARK: - Properties
    
    weak var delegate: AddLocationProtocolDelegate?
    private let searchBar = UISearchBar()
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]() {
        didSet { //once the searchResults gets set (in the completerDidUpdateResults() function) then we're going to reload our cells
            tableView.reloadData()
        }
    }
    private let type: LocationType
    private let location: CLLocation
    
    // MARK: - LifeCycle
    
    init(type: LocationType, location: CLLocation) {
        self.type = type
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureSearchBar()
        configureSearchCompleter()
        
//        print("DEBUG: Type is \(type.description)")
//        print("DEBUG: Location is \(location)")
    }
    
    //MARK: - Helper Functions
    
    func configureTableView() {
        //we dont need to use a custom cell we gonna just use the standard one
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView() //delete the extra seperator lines between the unuseble cells
        tableView.rowHeight = 60
        tableView.addShadow()
    }
    
    func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    func configureSearchCompleter() {
        //set a specefic region to search inside
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        searchCompleter.region = region
        searchCompleter.delegate = self
    }
}

//MARK: - UITableViewDelegate/DataSource

extension AddLocationController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let result = searchResults[indexPath.row]
        let title = result.title
        let subtitle = result.subtitle
        let locationString = title + " " + subtitle
        let trimmedLocation = locationString.replacingOccurrences(of: ", United States", with: "")
        delegate?.updatLocation(locationString: trimmedLocation, type: type)
    }
}

//MARK: - UISearchBarDelegate

extension AddLocationController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print("DEBUG: The Text is \(searchText)")
        searchCompleter.queryFragment = searchText //we set the queryFragment of the searchCompleter with the typed text (wich is updated every time the user type or delete)
    }
}

//MARK: - MKLocalSearchCompleterDelegate
// use that queryFragment to get the resualts
extension AddLocationController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
//        print("DEBUG: Search Results : \(searchResults)")
    }
}
