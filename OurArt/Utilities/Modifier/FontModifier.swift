//
//  FontModifier.swift
//  OurArt
//
//  Created by Jongmo You on 16.11.23.
//

import Foundation
import SwiftUI

struct CustomNavigationBar: ViewModifier {
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont(name: "Objectivity-ExtraBold", size: 30)!]
        
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont(name: "Objectivity-ExtraBold", size: 17)!]
    }
    
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    
    func customNavigationBar() -> some View {
        self.modifier(CustomNavigationBar())
    }
}
