//
//  MapViewModel.swift
//  OurArt
//
//  Created by Jongmo You on 07.10.24.
//

import SwiftUI
import MapKit
import CoreLocation
import Contacts

class MapViewModel: ObservableObject {
    @Published var coordinate: CLLocationCoordinate2D?
    
    private let geocoder = CLGeocoder()
    
    func showAddress(for address: String?) {
        guard let address else { return }
        
        geocoder.cancelGeocode()
        
        // 주소 문자열에서 컴포넌트를 파싱하는 로직 추가
        if let parsedAddress = parseAddress(addressString: address) {
            let postalAddress = CNMutablePostalAddress()
            postalAddress.street = parsedAddress.street
            postalAddress.postalCode = parsedAddress.postalCode
            postalAddress.city = parsedAddress.city
            
            geocoder.geocodePostalAddress(postalAddress) { [weak self] placemarks, error in
                self?.handleGeocodeResult(placemarks: placemarks, error: error)
            }
        } else {
            // 파싱 실패 시, 기존 방식대로 처리 (안전장치)
            geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
                self?.handleGeocodeResult(placemarks: placemarks, error: error)
            }
        }
    }
    
    private func handleGeocodeResult(placemarks: [CLPlacemark]?, error: Error?) {
        if let coordinate = placemarks?.first?.location?.coordinate {
            DispatchQueue.main.async {
                self.coordinate = coordinate
                print(coordinate)
            }
        } else if let error = error {
            print("Geocoding error: \(error)")
        }
    }
    
    // 주소 문자열을 파싱하는 도우미 함수
    private func parseAddress(addressString: String) -> (street: String, postalCode: String, city: String)? {
        let components = addressString.components(separatedBy: ", ")
        guard components.count >= 3 else { return nil }
        
        let street = components[0]
        let postalCode = components[1]
        let city = components[2]
        
        return (street: street, postalCode: postalCode, city: city)
    }
    
    func openMapAtCoordinate(_ coordinate: CLLocationCoordinate2D, name: String? = nil) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps()
    }
    
    // 리버스 지오코딩을 통해 주소 정보를 얻어 맵을 엽니다.
    func openMap(_ coordinate: CLLocationCoordinate2D, name: String? = nil) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first else {
                print("Reverse geocoding error: \(error?.localizedDescription ?? "알 수 없는 오류")")
                
                // 리버스 지오코딩 실패 시 좌표만으로 맵을 엽니다.
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                mapItem.name = name
                mapItem.openInMaps()
                return
            }
            
            // 리버스 지오코딩 성공 시, 주소 정보가 담긴 MKPlacemark로 맵을 엽니다.
            let mkPlacemark = MKPlacemark(placemark: placemark)
            let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
            mapItem.name = mkPlacemark.name ?? name
            mapItem.openInMaps()
        }
    }
}

