//
//  FullScreenPosterView.swift
//  OurArt
//
//  Created by Jongmo You on 29.08.24.
//

import SwiftUI

struct FullScreenPosterView: View {
    @Binding var isZoomed: Bool
    var image: Image
    
    @State private var scale: CGFloat = 3.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .onTapGesture {
                    withAnimation {
                        isZoomed.toggle()
                    }
                }
            
            image
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 100, maxHeight: 150)
                .magnifiable(scale: $scale)
                .onTapGesture {
                    withAnimation {
                        isZoomed.toggle()
                    }
                }
        }
    }
}

#Preview {
    FullScreenPosterView(isZoomed: .constant(false), image: Image(systemName: "photo.on.rectangle.angled"))
}
