//
//  MapView.swift
//  OurArt
//
//  Created by Jongmo You on 24.10.24.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
//    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @Binding var selectedLatitude: Double?
    @Binding var selectedLongitude: Double?
    @Binding var region: MKCoordinateRegion?
    
    var annotations: [MKPointAnnotation]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // Kunstakademie Düsseldorf의 좌표
        let initialCoordinate = CLLocationCoordinate2D(latitude: 51.23043, longitude: 6.77491)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: initialCoordinate, span: span)
        
        mapView.setRegion(region, animated: false)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        updateAnnotations(from: uiView)
        if let region = region {
            uiView.setRegion(region, animated: true)
            context.coordinator.isUpdatingRegion = true
        } else if let latitude = selectedLatitude, let longitude = selectedLongitude {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            uiView.setCenter(coordinate, animated: true)
        }
    }
    
    private func updateAnnotations(from mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var isUpdatingRegion = false
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            if isUpdatingRegion {
                isUpdatingRegion = false
                parent.region = nil
            } else {
                DispatchQueue.main.async {
                    self.parent.selectedLatitude = mapView.centerCoordinate.latitude
                    self.parent.selectedLongitude = mapView.centerCoordinate.longitude
                }
            }
        }
    }
}
