//
//  MapSearchViewModel.swift
//  OurArt
//
//  Created by Jongmo You on 27.06.24.
//

import SwiftUI
import MapKit

class MapSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchResults: [LocalizedSearchResult] = []
    private var searchCompleter: MKLocalSearchCompleter
    private var geocoder = CLGeocoder()
    
    override init() {
        searchCompleter = MKLocalSearchCompleter()
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    func search(query: String) {
        searchCompleter.queryFragment = query
    }
    
    // MARK: - MKLocalSearchCompleterDelegate
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            let completions = completer.results
            self.searchResults = completions.map { LocalizedSearchResult(completion: $0) }
            for (index, _) in self.searchResults.enumerated() {
                geocodeAddress(for: index)
            }
        }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error finding autocomplete suggestions: \(error.localizedDescription)")
    }
    
    private func geocodeAddress(for index: Int) {
            let subtitle = searchResults[index].subtitle
            geocoder.geocodeAddressString(subtitle) { [weak self] placemarks, error in
                guard let self = self else { return }
                guard let placemark = placemarks?.first, error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    self.searchResults[index].localizedSubtitle = placemark.locality ?? subtitle
                }
            }
        }
}

struct LocalizedSearchResult: Hashable {
    let title: String
    let subtitle: String
    var localizedSubtitle: String
    
    init(completion: MKLocalSearchCompletion) {
        self.title = completion.title
        self.subtitle = completion.subtitle
        self.localizedSubtitle = completion.subtitle // Initialize with the original subtitle
    }
}
