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
    let posterNamespace: Namespace.ID
    let geometryId: String
    
    @State private var showToolbar = false
    @State private var isAtMinZoom = true
    @State private var resetZoomTick = 0

    var body: some View {
        ZStack(alignment: .center) {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
            
            image
                .resizable()
                .scaledToFit()
                .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                .clipShape(.rect(cornerRadius: 10))
                .matchedGeometryEffect(id: geometryId, in: posterNamespace)
                .zoomable(resetTrigger: resetZoomTick)
                .swipeDownToDismiss(isActive: $isZoomed)
                .onPreferenceChange(IsAtMinZoomPreferenceKey.self) { isMin in
                    isAtMinZoom = isMin
                }
            
            if showToolbar && isAtMinZoom {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        
                        Button {
                            withAnimation(.smooth(duration: 0.5)) {
                                isZoomed.toggle()
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .imageScale(.large)
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        }
        .onTapGesture {
            withAnimation(.smooth(duration: 0.5)) {
                showToolbar = true
                resetZoomTick &+= 1
            }
        }
    }
}
