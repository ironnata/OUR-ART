//
//  GooglePlacesAutocomplete.swift
//  OurArt
//
//  Created by Jongmo You on 15.07.24.
//

import SwiftUI
import GooglePlaces

struct GooglePlacesAutocomplete: UIViewControllerRepresentable {
    @Binding var selectedPlace: GMSPlace?
    @Binding var showAutocomplete: Bool
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> GMSAutocompleteViewController {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = context.coordinator
        return autocompleteController
    }
    
    func updateUIViewController(_ uiViewController: GMSAutocompleteViewController, context: Context) {}
    
    class Coordinator: NSObject, GMSAutocompleteViewControllerDelegate {
        var parent: GooglePlacesAutocomplete
        
        init(_ parent: GooglePlacesAutocomplete) {
            self.parent = parent
        }
        
        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
            parent.selectedPlace = place
            parent.showAutocomplete = false
        }
        
        func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
            print("Error: \(error.localizedDescription)")
            parent.showAutocomplete = false
        }
        
        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            parent.showAutocomplete = false
        }
    }
}
