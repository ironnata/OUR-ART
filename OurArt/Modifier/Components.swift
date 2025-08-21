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

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.secondAccent)
                
                Text(title)
                    .foregroundColor(.secondAccent)
                
                Spacer()
            }
            
            content
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.redacted)
        .clipShape(.rect(cornerRadius: 8))
    }
}
