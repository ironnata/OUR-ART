//
//  MyExhibitionsView.swift
//  OurArt
//
//  Created by Jongmo You on 29.04.24.
//

import SwiftUI

@MainActor
final class MyExhibitionViewModel: ObservableObject {
    
    @Published private(set) var userMyExhibitions: [UserMyExhibition] = []
    
    func getMyExhibitions() {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            var userMyExhibitions = try await UserManager.shared.getAllMyExhibitions(userId: authDataResult.uid)
            
            // 최신순 정렬 nil은 맨 나중으로 보내기
            userMyExhibitions.sort(by: { (exhibition1, exhibition2) -> Bool in
                let date1 = exhibition1.dateFrom ?? .distantPast
                let date2 = exhibition2.dateFrom ?? .distantPast
                return date1 > date2
            })
            
            self.userMyExhibitions = userMyExhibitions
        }
    }
    
    // Favorite 기능 넣으면 쓸 기능 // 추가로 디벨롭하여 유저의 전시삭제 기능
    func removeMyExhibitions(myExhibitionId: String) {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            
            try? await UserManager.shared.removeMyExhibition(userId: authDataResult.uid, myExhibitionId: myExhibitionId)
            
//            try await ExhibitionManager.shared.deleteExhibition(exhibitionId: myExhibitionId)
            // path를 어떻게 선언할지 방법을 찾아야 함
//            if let path = exhibition.posterImagePath {
//                try await StorageManager.shared.deleteImage(path: path)
//            }
            
            getMyExhibitions()
        }
    }
}

struct MyExhibitionsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = MyExhibitionViewModel()
    
    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.userMyExhibitions, id: \.id.self) { item in
                    ExhibitionCellViewBuilder(exhibitionId: item.exhibitionId)
                        .contextMenu(menuItems: {
                            Button("Remove from Favorites") {
                                // Favorite func 만들어서 변경
                                viewModel.removeMyExhibitions(myExhibitionId: item.id)
                            }
                        })
                }
                .sectionBackground()
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
        .navigationTitle("My Exhibitions")
        .onAppear {
            viewModel.getMyExhibitions()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .onTapGesture {
                        dismiss()
                    }
            }
        }
        .viewBackground()
    }
}

#Preview {
    MyExhibitionsView()
}
