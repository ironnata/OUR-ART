//
//  Extensions.swift
//  OurArt
//
//  Created by Jongmo You on 04.04.24.
//

import Foundation
import SwiftUI


extension Font {
    
    static let objectivityLargeTitle = Font.custom("Objectivity-Bold", size: 32)
    
    static let objectivityTitle = Font.custom("Objectivity-Bold", size: 28)
    
    static let objectivityTitle2 = Font.custom("Objectivity-Bold", size: 23)
    
    static let objectivityBody = Font.custom("Objectivity-Medium", size: 17)
    
    static let objectivityCallout = Font.custom("Objectivity-Regular", size: 15)
    
    static let objectivityFootnote = Font.custom("Objectivity-Regular", size: 13)
    
    static let objectivityCaption = Font.custom("Objectivity-Regular", size: 10)
    
}

extension DateFormatter {
    static func localizedDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }
    
    static func timeOnlyFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
}

extension View {
    func sectionBackground() -> some View {
        self.listRowBackground(Color.background0)
    }
    
    func viewBackground() -> some View {
        self.background(.background0)
    }
    
    func customNavigationBar() -> some View {
        self.modifier(CustomNavigationBar())
    }
}



struct CustomNavigationBar: ViewModifier {
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont(name: "Objectivity-ExtraBold", size: 32)!]
        
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont(name: "Objectivity-Bold", size: 17)!]
    }
    
    func body(content: Content) -> some View {
        content
    }
}

