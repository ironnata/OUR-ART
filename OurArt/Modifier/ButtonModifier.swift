//
//  ButtonModifier.swift
//  OurArt
//
//  Created by Jongmo You on 13.10.23.
//

import SwiftUI

struct ButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundStyle(Color.white)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

