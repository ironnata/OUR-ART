//
//  SearchViewModel.swift
//  OurArt
//
//  Created by Jongmo You on 27.07.24.
//

import SwiftUI
import MapKit
import Combine

struct LocalizedSearchResult: Identifiable {
    var id = UUID()
    var name: String
    var formattedAddress: String
    var city: String?
    var coordinate: CLLocationCoordinate2D
}

class AddressSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchResults: [LocalizedSearchResult] = []
    @Published var queryFragment: String = ""
    
    private var completer: MKLocalSearchCompleter
    private var geocoder = CLGeocoder()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        self.completer = MKLocalSearchCompleter()
        super.init()
        self.completer.delegate = self
        
        $queryFragment
            .sink { [weak self] query in
                self?.completer.queryFragment = query
            }
            .store(in: &cancellables)
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results.map { completion in
            LocalizedSearchResult(name: completion.title, formattedAddress: completion.subtitle, coordinate: CLLocationCoordinate2D())
        }
    }
    
    func searchForSelectedResult(result: LocalizedSearchResult, completionHandler: @escaping (LocalizedSearchResult?) -> Void) {
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = result.name
            
            let search = MKLocalSearch(request: searchRequest)
            
            search.start { response, error in
                guard let mapItem = response?.mapItems.first else {
                    completionHandler(nil)
                    return
                }
                
                let coordinate = mapItem.placemark.coordinate
                self.geocodeAddress(for: coordinate) { placemark in
                    if let placemark = placemark {
                        let formattedAddress = self.formatAddress(from: placemark)
                        let city = placemark.locality
                        let result = LocalizedSearchResult(name: result.name, formattedAddress: formattedAddress, city: city, coordinate: coordinate)
                        completionHandler(result)
                    } else {
                        completionHandler(nil)
                    }
                }
            }
        }
    
    private func geocodeAddress(for coordinate: CLLocationCoordinate2D, completion: @escaping (CLPlacemark?) -> Void) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "de_DE")) { placemarks, error in
            completion(placemarks?.first)
        }
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        let components = [
            placemark.thoroughfare,
            placemark.subThoroughfare,
            placemark.postalCode,
            placemark.locality
        ]
        return components.compactMap { $0 }.joined(separator: ", ")
    }
}
