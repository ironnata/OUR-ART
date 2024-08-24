//
//  MapViewModel.swift
//  OurArt
//
//  Created by Jongmo You on 24.08.24.
//

import Foundation
import CoreLocation
import Combine

class MapViewModel: ObservableObject {
    @Published var coordinate: CLLocationCoordinate2D?
    private var cancellables = Set<AnyCancellable>()
    
    func fetchCoordinates(for address: String?) {
        
        guard let address else { return }
        CLGeocoder().geocodeAddressString(address) { [weak self] placemarks, error in
            if let coordinate = placemarks?.first?.location?.coordinate {
                DispatchQueue.main.async {
                    self?.coordinate = coordinate
                }
            } else if let error = error {
                print("Geocoding error: \(error)")
            }
        }
    }
}
