//
//  ExhibitionPosterView.swift
//  OurArt
//
//  Created by Jongmo You on 25.03.24.
//

import SwiftUI

struct ExhibitionPosterView: View {
    
    let exhibition: Exhibition
    
    var body: some View {
        ZStack {
            HStack {
                AsyncImage(url: URL(string: exhibition.posterImagePathUrl ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .modifier(BigPosterSizeModifier())
                } placeholder: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.redacted)
                            .opacity(0.7)
                        
                        Text(exhibition.title ?? "")
                            .foregroundStyle(.accent)
                    }
                    .frame(maxWidth: 280, maxHeight: 420)
                }
            }
        }
        .viewBackground()
    }
}

#Preview {
    ExhibitionPosterView(exhibition: Exhibition(id: "1"))
}
