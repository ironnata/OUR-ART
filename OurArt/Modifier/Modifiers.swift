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
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75)
            .clipShape(.rect(cornerRadius: 8))
    }
}

// MARK: - PROFILE IMAGE MODIFIER

struct ProfileImageModifer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fill)
            .frame(width: 150, height: 150)
            .clipShape(Circle())
    }
}

struct SmallProfileImageModifer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fill)
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

struct SwipeDownToDismissModifier: ViewModifier {
    @Binding var isActive: Bool
    var minStartX: CGFloat = 30
    var distanceThreshold: CGFloat = 50
    var velocityThreshold: CGFloat = 50

    @State private var draggedOffset: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .offset(draggedOffset)
            .gesture(
                DragGesture()
                    .onChanged { g in
                        guard g.location.x > minStartX, g.translation.height > 0 else { return }
                        draggedOffset = g.translation
                    }
                    .onEnded { g in
                        if isDismissable(g) { isActive = false }
                        draggedOffset = .zero
                    }
            )
    }

    private func isDismissable(_ g: DragGesture.Value) -> Bool {
        let enoughDistance = g.translation.height > distanceThreshold
        let predictedDelta = g.predictedEndLocation - g.location
        let enoughVelocity = predictedDelta.y > velocityThreshold
        return enoughDistance || enoughVelocity
    }
}


// Zoomable Modifier
struct ZoomableModifier: ViewModifier {
    let minZoomScale: CGFloat
    let maxZoomScale: CGFloat?
    let doubleTapZoomScale: CGFloat?
    let resetTrigger: Int?

    @State private var lastTransform: CGAffineTransform = .identity
    @State private var transform: CGAffineTransform = .identity
    @State private var contentSize: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .background(alignment: .topLeading) {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            contentSize = proxy.size
                        }
                }
            }
            .animatableTransformEffect(transform)
            .gesture(
                dragGesture,
                including: transform == .identity ? .none : .all
            )
            .modify { view in
                if #available(iOS 17.0, *) {
                    view.gesture(magnificationGesture)
                } else {
                    view.gesture(oldMagnificationGesture)
                }
            }
            .modify { view in
                if let doubleTapZoomScale {
                    view.gesture(doubleTapGesture(doubleTapZoomScale))
                } else {
                    view
                }
            }
            .preference(key: IsAtMinZoomPreferenceKey.self, value: transform.isIdentity)
            .onChange(of: resetTrigger) { _, _ in
                // 외부에서 resetTrigger 값이 바뀌면 배율 초기화
                let newTransform: CGAffineTransform = .identity
                withAnimation(.snappy(duration: 0.1)) {
                    transform = newTransform
                    lastTransform = newTransform
                }
            }
    }

    @available(iOS, introduced: 16.0, deprecated: 17.0)
    private var oldMagnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let zoomFactor = 0.5
                let scale = value * zoomFactor
                transform = lastTransform.scaledBy(x: scale, y: scale)
            }
            .onEnded { _ in
                onEndGesture()
            }
    }

    @available(iOS 17.0, *)
    private var magnificationGesture: some Gesture {
        MagnifyGesture(minimumScaleDelta: 0)
            .onChanged { value in
                let newTransform = CGAffineTransform.anchoredScale(
                    scale: value.magnification,
                    anchor: value.startAnchor.scaledBy(contentSize)
                )

                withAnimation(.interactiveSpring) {
                    transform = lastTransform.concatenating(newTransform)
                }
            }
            .onEnded { _ in
                onEndGesture()
            }
    }

    private func doubleTapGesture(_ zoomScale: CGFloat) -> some Gesture {
        SpatialTapGesture(count: 2)
            .onEnded { value in
                let newTransform: CGAffineTransform =
                    if transform.isIdentity {
                        .anchoredScale(scale: zoomScale, anchor: value.location)
                    } else {
                        .identity
                    }

                withAnimation(.linear(duration: 0.15)) {
                    transform = newTransform
                    lastTransform = newTransform
                }

                onEndGesture()
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(.interactiveSpring) {
                    transform = lastTransform.translatedBy(
                        x: value.translation.width
                            / max(transform.scaleX, .leastNonzeroMagnitude),
                        y: value.translation.height
                            / max(transform.scaleY, .leastNonzeroMagnitude)
                    )
                }
            }
            .onEnded { _ in
                onEndGesture()
            }
    }

    private func onEndGesture() {
        let newTransform = limitTransform(transform)

        withAnimation(.snappy(duration: 0.1)) {
            transform = newTransform
            lastTransform = newTransform
        }
    }

    private func limitTransform(
        _ transform: CGAffineTransform
    ) -> CGAffineTransform {
        let scaleX = transform.scaleX
        let scaleY = transform.scaleY

        if scaleX < minZoomScale || scaleY < minZoomScale {
            return .identity
        }

        var capped = transform

        if let maxZoomScale {
            let currentScale = max(scaleX, scaleY)
            if currentScale > maxZoomScale {
                let factor = maxZoomScale / currentScale
                let contentCenter = CGPoint(
                    x: contentSize.width / 2,
                    y: contentSize.height / 2
                )
                let capTransform = CGAffineTransform.anchoredScale(
                    scale: factor,
                    anchor: contentCenter
                )
                capped = capped.concatenating(capTransform)
            }
        }

        let maxX = contentSize.width * (capped.scaleX - 1)
        let maxY = contentSize.height * (capped.scaleY - 1)

        if capped.tx > 0
            || capped.tx < -maxX
            || capped.ty > 0
            || capped.ty < -maxY
        {
            let tx = min(max(capped.tx, -maxX), 0)
            let ty = min(max(capped.ty, -maxY), 0)
            capped.tx = tx
            capped.ty = ty
        }

        return capped
    }
}

struct IsAtMinZoomPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = true
    static func reduce(value: inout Bool, nextValue: () -> Bool) { value = nextValue() }
}
