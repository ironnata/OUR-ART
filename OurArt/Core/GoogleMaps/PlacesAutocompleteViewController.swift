//
//  PlacesAutocompleteViewController.swift
//  OurArt
//
//  Created by Jongmo You on 15.07.24.
//

import SwiftUI
import GooglePlaces
import UIKit

class PlacesAutocompleteViewController: UIViewController {
    var placesClient: GMSPlacesClient!
    var tableView: UITableView!
    var searchController: UISearchController!
    var results: [GMSAutocompletePrediction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.background0  // 백그라운드 컬러 변경
        
        placesClient = GMSPlacesClient.shared()
        
        setupSearchController()
        setupTableView()
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for places"
        
        // 텍스트 필드 커스터마이징
        if let searchBarTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            searchBarTextField.backgroundColor = UIColor.gray
            searchBarTextField.layer.cornerRadius = 7
            searchBarTextField.layer.masksToBounds = true
            searchBarTextField.layer.shadowRadius = 3
            searchBarTextField.layer.shadowOpacity = 0.3
            searchBarTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        }
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: self.view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        view.addSubview(tableView)
    }
}

extension PlacesAutocompleteViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            results = []
            tableView.reloadData()
            return
        }
        
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        
        placesClient.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { (predictions, error) in
            if let error = error {
                print("Error finding predictions: \(error.localizedDescription)")
                return
            }
            
            self.results = predictions ?? []
            self.tableView.reloadData()
        }
    }
}

extension PlacesAutocompleteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let result = results[indexPath.row]
        cell.textLabel?.text = result.attributedFullText.string
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = results[indexPath.row]
        // 선택된 장소에 대한 작업 수행
        print("Selected place: \(result.attributedFullText.string)")
        searchController.isActive = false
    }
}



struct PlacesAutocompleteView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> PlacesAutocompleteViewController {
        return PlacesAutocompleteViewController()
    }
    
    func updateUIViewController(_ uiViewController: PlacesAutocompleteViewController, context: Context) {
        // 필요 시 업데이트 작업
    }
}
