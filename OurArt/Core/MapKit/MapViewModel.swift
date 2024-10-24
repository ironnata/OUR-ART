//
//  MapViewModel.swift
//  OurArt
//
//  Created by Jongmo You on 07.10.24.
//

import SwiftUI
import MapKit

class MapViewModel: ObservableObject {
    @Published var coordinate: CLLocationCoordinate2D?
    
    func showAddress(for address: String?) {
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

