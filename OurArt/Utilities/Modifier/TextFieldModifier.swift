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
            .font(.subheadline)
            .padding()
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
