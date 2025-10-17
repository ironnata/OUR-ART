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
    
    private let geocoder = CLGeocoder()
    
    func showAddress(for address: String?) {
        guard let address else { return }
        
        geocoder.cancelGeocode()
        
        geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
            guard let self else { return }
            
            if let coordinate = placemarks?.first?.location?.coordinate {
                DispatchQueue.main.async {
                    self.coordinate = coordinate
                    print(coordinate)
                }
            } else if let error = error {
                print("Geocoding error: \(error)")
            }
        }
    }
    
    func openMapAtCoordinate(_ coordinate: CLLocationCoordinate2D, name: String? = nil) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

