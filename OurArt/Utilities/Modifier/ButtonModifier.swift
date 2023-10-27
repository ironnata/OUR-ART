//
//  ButtonModifier.swift
//  OurArt
//
//  Created by Jongmo You on 13.10.23.
//

import SwiftUI

struct AuthButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3)
            .fontWeight(.medium)
            .foregroundStyle(Color.white)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

struct CommonButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .fontWeight(.medium)
            .foregroundStyle(Color.white)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

struct SmallButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(Color.accentColor)
            .frame(width: 40, height: 15)
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.secondary, lineWidth: 1)
                    .background(Color.white)
            }
    }
}
