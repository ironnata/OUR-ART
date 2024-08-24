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
                        let result = LocalizedSearchResult(name: result.name, formattedAddress: formattedAddress, coordinate: coordinate)
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

//struct LocalizedSearchResult: Identifiable {
//    var id = UUID()
//    var title: String
//    var subtitle: String
//    var coordinate: CLLocationCoordinate2D
//}
//
//class SearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
//    @Published var searchResults: [LocalizedSearchResult] = []
//    @Published var queryFragment: String = ""
//    
//    private var completer: MKLocalSearchCompleter
//    private var geocoder = CLGeocoder()
//    private var cancellables = Set<AnyCancellable>()
//    
//    override init() {
//        self.completer = MKLocalSearchCompleter()
//        super.init()
//        self.completer.delegate = self
//        
//        $queryFragment
//            .sink { [weak self] query in
//                self?.completer.queryFragment = query
//            }
//            .store(in: &cancellables)
//    }
//    
//    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
//        self.searchResults = completer.results.map { completion in
//            LocalizedSearchResult(title: completion.title, subtitle: completion.subtitle, coordinate: CLLocationCoordinate2D())
//        }
//        updateSearchResultsWithCoordinates(completer.results)
//    }
//    
//    private func updateSearchResultsWithCoordinates(_ results: [MKLocalSearchCompletion]) {
//        let group = DispatchGroup()
//        
//        for (index, result) in results.enumerated() {
//            group.enter()
//            let searchRequest = MKLocalSearch.Request(completion: result)
//            let search = MKLocalSearch(request: searchRequest)
//            
//            search.start { response, error in
//                defer { group.leave() }
//                guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
//                
//                self.geocodeAddress(for: coordinate) { address in
//                    DispatchQueue.main.async {
//                        if let address = address {
//                            self.searchResults[index].title = address.title
//                            self.searchResults[index].subtitle = address.subtitle
//                        }
//                    }
//                }
//            }
//        }
//        
//        group.notify(queue: .main) {
//            // All geocoding is complete
//        }
//    }
//    
//    private func geocodeAddress(for coordinate: CLLocationCoordinate2D, completion: @escaping (LocalizedSearchResult?) -> Void) {
//        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        geocoder.reverseGeocodeLocation(location, preferredLocale: nil) { placemarks, error in
//            guard let placemark = placemarks?.first else {
//                completion(nil)
//                return
//            }
//            
//            let title = [placemark.thoroughfare, placemark.subThoroughfare].compactMap { $0 }.joined(separator: " ")
//            let subtitle = [placemark.locality, placemark.administrativeArea, placemark.country].compactMap { $0 }.joined(separator: ", ")
//            completion(LocalizedSearchResult(title: title, subtitle: subtitle, coordinate: coordinate))
//        }
//    }
//}
