//
//  ExhibitionCellView.swift
//  OurArt
//
//  Created by Jongmo You on 02.11.23.
//

import SwiftUI

struct ExhibitionCellView: View {
    var title: String
    var poster: String
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .padding(.bottom, 10)
                
                CellDetailView(icon: "calendar", text: "01.11.2023 - 11.11.2023")
                CellDetailView(icon: "mappin.and.ellipse", text: "Heinrich Heine Allee 21")
            }
            .font(.footnote)
            
            Spacer()
            
            Image(poster)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 100)
                .padding(.leading, 20)
        }
        .frame(maxWidth: .infinity)
        .padding()
        
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(.secondary, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

#Preview {
    ExhibitionCellView(title: "Main Title", poster: "IMG_3245 2")
}



struct CellDetailView: View {
    var icon: String
    var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                Text(text)
            }
        }
    }
}
