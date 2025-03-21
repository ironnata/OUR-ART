//
//  AddressSearchViewModel.swift
//  OurArt
//
//  Created by Jongmo You on 08.10.24.
//

import SwiftUI
import MapKit
import Combine

struct SearchCompletions: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
}

struct SearchResult: Identifiable, Hashable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class AddressSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchResults: [SearchResult] = []
    @Published var queryFragment: String = ""
    @Published var selectedLocation: SearchResult?
    
    @Published var selectedAddress: String = ""
    @Published var selectedTitle: String = ""
    @Published var selectedCity: String = ""
    
    var completions = [SearchCompletions]()
    
    private let completer: MKLocalSearchCompleter
    private var geocoder = CLGeocoder()
    private var cancellables: Set<AnyCancellable> = []
    
    init(completer: MKLocalSearchCompleter) {
        self.completer = MKLocalSearchCompleter()
        super.init()
        self.completer.delegate = self
        self.completer.resultTypes = [.address, .pointOfInterest]
        
        $queryFragment
            .sink { [weak self] query in
                self?.completer.queryFragment = query
            }
            .store(in: &cancellables)
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results.map { completion in
            return .init(
                title: completion.title,
                subtitle: completion.subtitle
            )
        }
    }
    
    func search(for query: String, coordinate: CLLocationCoordinate2D? = nil) async throws -> [SearchResult] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.pointOfInterest, .address]
        
        if let coordinate {
            request.region = .init(.init(origin: .init(coordinate), size: .init(width: 1, height: 1)))
        }
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        return response.mapItems.compactMap { mapItem in
            guard let location = mapItem.placemark.location?.coordinate else { return nil }
            
            return SearchResult(coordinate: location)
        }
    }
    
    func updateAddress(for coordinate: CLLocationCoordinate2D) async throws {
        let placemarks = try await geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), preferredLocale: Locale(identifier: "de_DE"))
        
        if let placemark = placemarks.first {
            let address = formatAddress(from: placemark)
            let title = formatPOI(from: placemark)
            let city = placemark.locality ?? ""
            
            await MainActor.run {
                self.selectedAddress = address
                self.selectedTitle = title
                self.selectedCity = city
            }
        }
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        let address = [placemark.thoroughfare, placemark.subThoroughfare]
            .compactMap { $0 }
            .joined(separator: " ")
        
        let additionalComponents = [placemark.postalCode, placemark.locality]
            .compactMap { $0 }
            .joined(separator: ", ")
        
        return [address, additionalComponents]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
    
    private func formatPOI(from placemark: CLPlacemark) -> String {
        return placemark.name ?? placemark.thoroughfare ?? ""
    }
}
