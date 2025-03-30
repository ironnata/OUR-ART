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
    
    // EnvironmentObject로 ExhibitionViewModel 받기
    @EnvironmentObject var exhibitionVM: ExhibitionViewModel
    
    var body: some View {
        ZStack {
            // 모든 전시 데이터 중에서 현재 ID와 일치하는 것을 찾아서 사용
            if let exhibition = exhibitionVM.exhibitions.first(where: { $0.id == exhibitionId }) {
                NavigationLink(destination: ExhibitionDetailView(
                    myExhibitionId: myExhibitionId, 
                    exhibitionId: exhibitionId, 
                    isMyExhibition: myExhibitionId != nil
                )) {
                    ExhibitionCellView(exhibition: exhibition)
                }
            } else {
                // 데이터가 아직 로드되지 않은 경우 플레이스홀더 표시
                ProgressView()
                    .frame(height: 80)
            }
        }
        // task 블록 제거 - 더 이상 여기서 데이터를 로드하지 않음
    }
}

#Preview {
    // Preview에서는 mockViewModel을 생성하여 사용
    let mockViewModel = ExhibitionViewModel()
    return ExhibitionCellViewBuilder(exhibitionId: "3B5DEAFF-96F6-409F-A67B-1951C38E20AF", myExhibitionId: "")
        .environmentObject(mockViewModel)
}
