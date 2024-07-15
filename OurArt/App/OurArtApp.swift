//
//  OurArtApp.swift
//  OurArt
//
//  Created by Jongmo You on 11.10.23.
//

import SwiftUI
import Firebase
import GoogleMaps
import GooglePlaces

@main
struct OurArtApp: App {
    
    init() {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .black
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .environment(\.font, Font.custom("Objectivity-Medium", size: 17))
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Configured Firebase!")
        
        GMSServices.provideAPIKey("AIzaSyB0diZef53W5Q1SVsy6MNw8N9v18OPN_ww")
        GMSPlacesClient.provideAPIKey("AIzaSyB0diZef53W5Q1SVsy6MNw8N9v18OPN_ww")
        print("Configured Google Maps!")
        
        return true
    }
}
