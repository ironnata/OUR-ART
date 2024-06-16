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
                    Text(exhibition.title ?? "")
                        .frame(width: 280, height: 420)
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color(UIColor.systemGray4), lineWidth: 2)
//                        }
                }
            }
        }
        .viewBackground()
    }
}

#Preview {
    ExhibitionPosterView(exhibition: Exhibition(id: "1"))
}
