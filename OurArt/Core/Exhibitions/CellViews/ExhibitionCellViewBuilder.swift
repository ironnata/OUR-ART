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
    
    @EnvironmentObject var exhibitionVM: ExhibitionViewModel
    @State private var exhibition: Exhibition?
    
    var body: some View {
        ZStack {
            if let exhibition = exhibition {
                NavigationLink(destination: ExhibitionDetailView(
                    myExhibitionId: myExhibitionId, 
                    exhibitionId: exhibitionId, 
                    isMyExhibition: myExhibitionId != nil
                )) {
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

#Preview {
    // Preview에서는 mockViewModel을 생성하여 사용
    let mockViewModel = ExhibitionViewModel()
    return ExhibitionCellViewBuilder(exhibitionId: "3B5DEAFF-96F6-409F-A67B-1951C38E20AF", myExhibitionId: "")
        .environmentObject(mockViewModel)
}
