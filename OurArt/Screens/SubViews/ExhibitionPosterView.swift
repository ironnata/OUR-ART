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
                    .frame(width: 270, height: 400) // Poster 사이즈 규격에 맞게 변경
            } placeholder: {
                Text(exhibition.title ?? "")
                    .frame(width: 270, height: 400)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(UIColor.systemGray4), lineWidth: 4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ExhibitionPosterView(exhibition: Exhibition(id: "1"))
}
