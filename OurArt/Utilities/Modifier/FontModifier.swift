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
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont(name: "Objectivity-ExtraBold", size: 32)!]
        
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont(name: "Objectivity-Bold", size: 17)!]
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

extension Font {
    
    static let objectivityLargeTitle = Font.custom("Objectivity-Bold", size: 32)
    
    static let objectivityTitle = Font.custom("Objectivity-Bold", size: 28)
    
    static let objectivityBody = Font.custom("Objectivity-Medium", size: 17)
    
    static let objectivityFootnote = Font.custom("Objectivity-Light", size: 15)
    
    static let objectivityCaption = Font.custom("Objectivity-Regular", size: 10)
    
}
