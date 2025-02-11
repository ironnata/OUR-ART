//
//  FullScreenProfileImage.swift
//  OurArt
//
//  Created by Jongmo You on 15.08.24.
//

import SwiftUI

struct FullScreenProfileImageView: View {
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
                .clipShape(Circle())
                .frame(width: 300, height: 300)
                .zoomable(isZoomed: $isZoomed)
                .onTapGesture {
                    withAnimation(.smooth) {
                        isZoomed.toggle()
                    }
                }
        }
    }
}

#Preview {
    FullScreenProfileImageView(isZoomed: .constant(false), image: Image(systemName: "person.circle.fill"))
}
