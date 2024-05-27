//
//  ButtonModifier.swift
//  OurArt
//
//  Created by Jongmo You on 13.10.23.
//

import SwiftUI


// MARK: - BUTTON MODIFIER

struct AuthButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3)
            .fontWeight(.medium)
            .foregroundStyle(Color.accentButton)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

struct CommonButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.objectivityBody)
            .foregroundStyle(Color.accentButton)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

struct SmallButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.objectivityFootnote)
            .foregroundStyle(Color.accentColor)
            .frame(width: 45, height: 20)
            .background(Color.accentButton)
            .overlay {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(.secondary, lineWidth: 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 3))
    }
}

// MARK: - TEXTFIELD MODIFIER

struct TextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.objectivityCallout)
            .padding()
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}


struct TextFieldDescriptionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.objectivityCallout)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}


struct OnFirstAppearViewModifier: ViewModifier {
    
    @State private var didAppear: Bool = false
    let perform: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if !didAppear {
                    perform?()
                    didAppear = true
                }
            }
    }
}
