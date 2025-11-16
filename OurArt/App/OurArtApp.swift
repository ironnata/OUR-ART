//
//  OurArtApp.swift
//  OurArt
//
//  Created by Jongmo You on 11.10.23.
//

import SwiftUI
import Firebase
import GoogleMobileAds
import FacebookCore

@main
struct OurArtApp: App {
    
//    init() {
//        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .black
//    }
    init() {
        // 디스크 캐시 용량을 500MB로 제한
        let diskCapacity = 500 * 1024 * 1024 // 500 MB
        let memoryCapacity = 50 * 1024 * 1024 // 메모리 캐시는 필요시 조정
        
        URLCache.shared = URLCache(memoryCapacity: memoryCapacity,
                                   diskCapacity: diskCapacity,
                                   diskPath: nil)
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .environment(\.font, Font.custom("Objectivity-Regular", size: 17))
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Configured Firebase!")
        
        MobileAds.shared.start(completionHandler: nil)
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
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
