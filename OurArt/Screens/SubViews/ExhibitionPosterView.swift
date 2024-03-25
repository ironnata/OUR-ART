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
        HStack {
            AsyncImage(url: URL(string: exhibition.posterImagePathUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill() // scaledToFit 으로 변경
                    .frame(width: 270, height: 400)
            } placeholder: {
                Text(exhibition.title ?? "")
                    .frame(width: 270, height: 400)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.secondary, lineWidth: 5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    ExhibitionPosterView(exhibition: Exhibition(id: "1"))
}
