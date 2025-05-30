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
            let currentDate = Calendar.current.startOfDay(for: Date())
            
            HStack {
                AsyncImage(url: URL(string: exhibition.posterImagePathUrl ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .modifier(SmallPosterSizeModifier())
                        .opacity(exhibition.dateTo != nil && currentDate > exhibition.dateTo! ? 0.3 : 1.0)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.redacted)
                        .modifier(SmallPosterSizeModifier())
                }
                .padding(.trailing, 10)
                .overlay {
                    if exhibition.dateTo != nil && currentDate > exhibition.dateTo! {
                        Image(systemName: "calendar.badge.minus")
                            .font(.title)
                            .symbolRenderingMode(.hierarchical)
                            .offset(x: -5)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(exhibition.title ?? "")
                        .lineLimit(1)
                        .padding(.bottom, 8)
                        .foregroundStyle(exhibition.dateTo != nil && currentDate > exhibition.dateTo! ? Color.secondAccent : Color.accent)
                    
                    if let dateFrom = exhibition.dateFrom,
                       let dateTo = exhibition.dateTo {
                        let dateFormatter = DateFormatter.localizedDateFormatter()
                        let formattedDateFrom = dateFormatter.string(from: dateFrom)
                        let formattedDateTo = dateFormatter.string(from: dateTo)
                        
                        CellDetailView(icon: "calendar", text: "\(formattedDateFrom) - \(formattedDateTo)")
                            .foregroundStyle(exhibition.dateTo != nil && currentDate > exhibition.dateTo! ? Color.secondAccent : Color.accent)
                            .offset(y: 7)
                    }
                    
                    CellDetailView(icon: "mappin.and.ellipse", text: exhibition.city ?? "no information")
                        .foregroundStyle(exhibition.dateTo != nil && currentDate > exhibition.dateTo! ? Color.secondAccent : Color.accent)
                }
                
                Spacer()
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
//            .padding()
//            .overlay {
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(.secondary, lineWidth: 2)
//            }
        }
        .viewBackground()
    }
}

#Preview {
    ExhibitionCellView(exhibition: Exhibition(id: "1908DE4D-3D36-45B8-82F8-501E2F6ED739"))
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
