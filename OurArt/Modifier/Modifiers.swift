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
            .background(Color.accent)
            .clipShape(.rect(cornerRadius: 5))
    }
}

struct CommonButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.objectivityBody)
            .foregroundStyle(Color.accentButtonText)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.accent)
            .clipShape(.rect(cornerRadius: 7))
    }
}

struct MediumSmallButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.objectivityCallout)
            .foregroundStyle(Color.accent)
            .frame(width: 72, height: 30)
            .background(Color.redacted)
            .clipShape(.rect(cornerRadius: 5))
    }
}

struct SmallButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.objectivityFootnote)
            .foregroundStyle(Color.accentButtonText)
            .frame(height: 20)
            .padding(.horizontal, 5)
            .background(Color.secondAccent)
            .clipShape(.rect(cornerRadius: 3))
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
                        .foregroundColor(.secondAccent)
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
            .clipShape(.rect(cornerRadius: 7))
    }
}


struct TextFieldDescriptionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.objectivityCallout)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            .clipShape(.rect(cornerRadius: 7))
    }
}


// MARK: - POSTER MODIFIER

struct SmallPosterSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: 50)
            .clipShape(.rect(cornerRadius: 2))
    }
}


struct MidPosterSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: 120)
            .clipShape(.rect(cornerRadius: 4))
    }
}


struct BigPosterSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: 280)
            .clipShape(.rect(cornerRadius: 8))
    }
}

// MARK: - PROFILE IMAGE MODIFIER

struct ProfileImageModifer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 150, height: 150)
            .clipShape(Circle())
    }
}

struct SmallProfileImageModifer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 45, height: 45)
            .clipShape(Circle())
    }
}



// MARK: - ETC

struct SectionHeaderBackgroundColormodifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.objectivityCallout)
            .frame(maxWidth: .infinity, maxHeight: .infinity ,alignment: .leading)
            .padding(.leading, 20)
            .background(Color.background0)
            .listRowInsets(EdgeInsets())
    }
}

struct ToolbarBackButton: ToolbarContent {
    @Environment(\.dismiss) var dismiss
    
    var body: some ToolbarContent {
        CompatibleToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
            }
        }
    }
}

struct CompatibleToolbarItem<Content: View>: ToolbarContent {
    let placement: ToolbarItemPlacement
    let content: Content
    
    init(placement: ToolbarItemPlacement, @ViewBuilder content: () -> Content) {
        self.placement = placement
        self.content = content()
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            content
        }
        .apply { item in
            if #available(iOS 26.0, *) {
                item.sharedBackgroundVisibility(.hidden)
            } else {
                item
            }
        }
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

struct KeyboardAware: ViewModifier {
    var minDistance: CGFloat
    @ObservedObject private var keyboard = KeyboardInfo.shared
    
    func body(content: Content) -> some View {
        content
            .safeAreaPadding(.bottom, keyboard.height > 0 ? minDistance : 0)
    }
}


struct ZoomableModifier: ViewModifier {
    @Binding var isZoomed: Bool

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    func body(content: Content) -> some View {
        GeometryReader { proxy in
            let size = proxy.size
            content
                .scaleEffect(scale)
                .offset(offset)
                .frame(width: size.width, height: size.height, alignment: .center)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let newScale = lastScale * value
                                scale = max(1.0, min(newScale, 3.0))
                            }
                            .onEnded { _ in
                                lastScale = scale
                                // 확대/축소 후 offset clamp
                                offset = clampOffset(offset, scale: scale, size: size)
                                lastOffset = offset
                            },
                        DragGesture()
                            .onChanged { value in
                                let newOffset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                                offset = clampOffset(newOffset, scale: scale, size: size)
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                )
                .onChange(of: isZoomed) { _, newValue in
                    if !newValue {
                        withAnimation(.smooth) {
                            scale = 1.0
                            lastScale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        }
                    }
                }
        }
    }

    private func clampOffset(_ offset: CGSize, scale: CGFloat, size: CGSize) -> CGSize {
        let maxX = (size.width * (scale - 1)) / 2
        let maxY = (size.height * (scale - 1)) / 2
        return CGSize(
            width: min(max(offset.width, -maxX), maxX),
            height: min(max(offset.height, -maxY), maxY)
        )
    }
}
