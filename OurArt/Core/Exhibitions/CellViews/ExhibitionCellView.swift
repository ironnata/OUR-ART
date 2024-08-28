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
        ZStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(exhibition.title ?? "n/a")
                        .foregroundStyle(.primary)
                        .padding(.bottom, 20)
                    
                    if let dateFrom = exhibition.dateFrom,
                       let dateTo = exhibition.dateTo {
                        let dateFormatter = DateFormatter.localizedDateFormatter()
                        let formattedDateFrom = dateFormatter.string(from: dateFrom)
                        let formattedDateTo = dateFormatter.string(from: dateTo)
                        
                        CellDetailView(icon: "calendar", text: "\(formattedDateFrom) - \(formattedDateTo)")
                    }
                    
                    CellDetailView(icon: "mappin.and.ellipse", text: exhibition.city ?? "no information")
                }
                
                Spacer()
                
                AsyncImage(url: URL(string: exhibition.posterImagePathUrl ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .modifier(SmallPosterSizeModifier())
                } placeholder: {
                    EmptyView()
                        .modifier(SmallPosterSizeModifier())
                }
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.secondary, lineWidth: 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .viewBackground()
    }
}

#Preview {
    ExhibitionCellView(exhibition: Exhibition(id: "1"))
}



struct CellDetailView: View {
    var icon: String
    var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .font(.footnote)
                    .padding(.bottom, 5)
                Text(text)
                    .font(.objectivityFootnote)
            }
        }
    }
}
