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
                .frame(maxWidth: 300)
                .clipShape(.rect(cornerRadius: 8))
                .zoomable(isZoomed: $isZoomed)
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
