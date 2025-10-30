//
//  ExhibitionCellViewBuilder.swift
//  OurArt
//
//  Created by Jongmo You on 30.04.24.
//

import SwiftUI

struct ExhibitionCellViewBuilder: View {
    
    let exhibitionId: String
    let myExhibitionId: String?
    let favExhibitionId: String?
    
    @EnvironmentObject var exhibitionVM: ExhibitionViewModel
    @State private var exhibition: Exhibition?
    
    var body: some View {
        ZStack {
            if let exhibition = exhibition {
                ZStack {
                    NavigationLink(destination: ExhibitionDetailView(
                        exhibitionId: exhibitionId,
                        myExhibitionId: myExhibitionId,
                        isMyExhibition: myExhibitionId != nil,
                        favExhibitionId: favExhibitionId,
                        isFavExhibition: favExhibitionId != nil
                    )) {
                        EmptyView()
                    }
                    .opacity(0)
                    
                    ExhibitionCellView(exhibition: exhibition)
                }
            } else {
                ProgressView()
                    .frame(height: 80)
            }
        }
        .onChange(of: exhibitionVM.exhibitions) { _, newExhibitions in
            exhibition = newExhibitions.first(where: { $0.id == exhibitionId })
        }
        .onAppear {
            exhibition = exhibitionVM.exhibitions.first(where: { $0.id == exhibitionId })
        }
    }
}

