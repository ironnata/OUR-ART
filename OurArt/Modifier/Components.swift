//
//  Components.swift
//  OurArt
//
//  Created by Jongmo You on 17.07.25.
//

import Foundation
import SwiftUI

struct BannerMessage: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.objectivityCallout)
            .foregroundColor(.accentButtonText)
            .lineSpacing(5)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(Color.accent.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}
