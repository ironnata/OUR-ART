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
                Text(exhibition.title ?? "n/a")
                    .foregroundStyle(.primary)
                    .padding(.bottom, 10)
                
                if let dateFrom = exhibition.dateFrom?.formatted(.iso8601.year().month().day()),
                    let dateTo = exhibition.dateTo?.formatted(.iso8601.year().month().day()) {
                    CellDetailView(icon: "calendar", text: "\(dateFrom) - \(dateTo)")
                }
                
                CellDetailView(icon: "mappin.and.ellipse", text: exhibition.address ?? "none")
            }
            
            Spacer()
            
            AsyncImage(url: URL(string: exhibition.posterImagePathUrl ?? "")) { image in
                image
                    .resizable()
                    .frame(width: 80, height: 100)
            } placeholder: {
                ProgressView()
                    .frame(width: 80, height: 100)
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding()
        
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.secondary, lineWidth: 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
