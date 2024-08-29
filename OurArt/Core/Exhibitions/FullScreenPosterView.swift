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
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isZoomed.toggle()
                    }
                }
            
            image
                .resizable()
                .scaledToFit()
                .modifier(BigPosterSizeModifier())
                .onTapGesture {
                    withAnimation(.smooth) {
                        isZoomed.toggle()
                    }
                }
        }
    }
}

#Preview {
    FullScreenPosterView(isZoomed: .constant(false), image: Image(systemName: "photo.on.rectangle.angled"))
}
