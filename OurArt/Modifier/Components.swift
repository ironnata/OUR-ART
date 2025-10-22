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

struct SectionCard<Content: View, ButtonContent: View>: View {
    let title: String
    let icon: String
    let content: Content
    let button: ButtonContent
    
    init(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content,
        @ViewBuilder button: () -> ButtonContent = { EmptyView() }
    ) {
        self.title = title
        self.icon = icon
        self.content = content()
        self.button = button()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.secondAccent)
                
                Text(title)
                    .foregroundColor(.secondAccent)
                    .font(.objectivityCallout)
                
                Spacer()
                
                button
            }
            
            content
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.redacted)
        .clipShape(.rect(cornerRadius: 8))
    }
}

struct SimpleExpandableTextView: View {
    let text: String
    @State private var isExpanded = false
    private let threshold: Int = 120 // 적당한 글자 수 임계값

    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .lineLimit(isExpanded ? nil : 3)
                .multilineTextAlignment(.leading)
                .lineSpacing(9)
                .font(.objectivityCallout)
                .padding(.top, 10)

            if text.count > threshold && !isExpanded {
                Button("... more") {
                    withAnimation {
                        isExpanded = true
                    }
                }
                .font(.objectivityCallout.weight(.semibold))
                .foregroundStyle(Color.secondAccent)
                .padding(.top, 2)
            }
        }
    }
}
