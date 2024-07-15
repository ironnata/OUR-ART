//
//  GooglePlacesManager.swift
//  OurArt
//
//  Created by Jongmo You on 15.07.24.
//

import SwiftUI
import GooglePlaces

class GooglePlacesManager: NSObject, ObservableObject, GMSAutocompleteFetcherDelegate {
    @Published var searchResults: [GMSPlace] = []
    private var fetcher: GMSAutocompleteFetcher?
    
    override init() {
        super.init()
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        self.fetcher = GMSAutocompleteFetcher(filter: filter)
        self.fetcher?.delegate = self
    }
    
    func updateQuery(_ query: String) {
        self.fetcher?.sourceTextHasChanged(query)
    }
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        let placesClient = GMSPlacesClient.shared()
        var places: [GMSPlace] = []
        
        let group = DispatchGroup()
        
        for prediction in predictions {
            group.enter()
            placesClient.fetchPlace(fromPlaceID: prediction.placeID, placeFields: [.name, .formattedAddress], sessionToken: nil) { (place, error) in
                if let place = place {
                    places.append(place)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.searchResults = places
        }
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
