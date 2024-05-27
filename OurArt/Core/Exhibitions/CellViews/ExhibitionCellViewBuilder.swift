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
    @State private var exhibition: Exhibition? = nil
    
    var body: some View {
        ZStack {
            if let exhibition {
                NavigationLink(destination: ExhibitionDetailView(myExhibitionId: myExhibitionId, exhibition: exhibition, isMyExhibition: true)) {
                    ExhibitionCellView(exhibition: exhibition)
                }
            }
        }
        .task {
            self.exhibition = try? await ExhibitionManager.shared.getExhibition(id: exhibitionId)
        }
    }
}

#Preview {
    ExhibitionCellViewBuilder(exhibitionId: "3B5DEAFF-96F6-409F-A67B-1951C38E20AF", myExhibitionId: "")
}
