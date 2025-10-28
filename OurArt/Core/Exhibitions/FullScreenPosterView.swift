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
    
    @State private var draggedOffset = CGSize.zero
    @State private var isActive = false
      
    
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
                .zoomable()
                .swipeDownToDismiss(isActive: $isZoomed)
            
            if showToolbar {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        
                        Button {
                            isZoomed.toggle()
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
            withAnimation(.easeOut) {
                showToolbar.toggle()
            }
        }
    }
}
