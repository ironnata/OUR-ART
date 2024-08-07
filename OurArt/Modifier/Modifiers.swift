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
            .foregroundStyle(Color.accentButtonText)
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
            .foregroundStyle(Color.accentButtonText)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

struct SmallButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.objectivityFootnote)
            .foregroundStyle(Color.accentButtonText)
            .frame(width: 45, height: 20)
            .background(Color.secondary)
            .overlay {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(.accent, lineWidth: 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 3))
    }
}

struct TextFieldClearButton: ViewModifier {
    @Binding var fieldText: String
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if !fieldText.isEmpty {
                    HStack {
                        Spacer()
                        Button {
                            fieldText = ""
                        } label: {
                            Image(systemName: "multiply.circle.fill")
                        }
                        .foregroundColor(.secondary)
                        .padding(.trailing, 10)
                    }
                }
            }
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
            .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}


struct TextFieldDescriptionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.objectivityCallout)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 7))
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


struct SmallPosterSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(CGSize(width: 2, height: 3), contentMode: .fill)
            .frame(maxWidth: 80, maxHeight: 120)
            .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}


struct MidPosterSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(CGSize(width: 2, height: 3), contentMode: .fill)
            .frame(maxWidth: 120)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}


struct BigPosterSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(CGSize(width: 2, height: 3), contentMode: .fill)
            .frame(width: 280, height: 420)
    }
}
