//
//  Extensions.swift
//  OurArt
//
//  Created by Jongmo You on 04.04.24.
//

import Foundation
import SwiftUI


// 날짜/시간 로컬라이징 Extension
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

