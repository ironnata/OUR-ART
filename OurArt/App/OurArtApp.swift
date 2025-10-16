//
//  OurArtApp.swift
//  OurArt
//
//  Created by Jongmo You on 11.10.23.
//

import SwiftUI
import Firebase
import GoogleMobileAds

@main
struct OurArtApp: App {
    
//    init() {
//        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .black
//    }
    
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
        
        MobileAds.shared.start(completionHandler: nil)
        
        // 다크 모드에 따라 tintColor 설정
        let appearance = UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
        
        if #available(iOS 13.0, *) {
            let userInterfaceStyle = UITraitCollection.current.userInterfaceStyle
            appearance.tintColor = (userInterfaceStyle == .dark) ? .white : .black
        } else {
            // iOS 13 이전 버전에서는 기본 색상 설정
            appearance.tintColor = .black
        }
        return true
    }
}
