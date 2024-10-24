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
                .clipShape(Circle())
                .frame(width: 100, height: 100)
                .magnifiable(scale: $scale)
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
