//
//  TextFieldModifier.swift
//  OurArt
//
//  Created by Jongmo You on 25.10.23.
//

import SwiftUI

struct TextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .padding()
            .frame(height: 48)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.secondary, lineWidth: 1)
            )
    }
}
