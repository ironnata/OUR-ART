//
//  ExhibitionCellView.swift
//  OurArt
//
//  Created by Jongmo You on 02.11.23.
//

import SwiftUI

struct ExhibitionCellView: View {
    
    let exhibition: Exhibition
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(exhibition.title ?? "")
                    .font(.custom("Objectivity-", size: 25))
                    .foregroundStyle(.primary)
                    .padding(.bottom, 10)
                
                CellDetailView(icon: "calendar", text: exhibition.date ?? "")
                CellDetailView(icon: "mappin.and.ellipse", text: exhibition.address ?? "")
            }
            .font(.footnote)
            
            Spacer()
            
            Image(exhibition.thumbnail ?? "")
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
    ExhibitionCellView(exhibition: Exhibition(id: 0, title: "Afternoon", description: "Good afternoon", date: "03.11.2023 - 14.11.2023", address: "Heinrich Heine Allee 21", openingTime: "10:00 - 18:00", closingDays: [], thumbnail: "IMG_3245 2", images: []))
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
