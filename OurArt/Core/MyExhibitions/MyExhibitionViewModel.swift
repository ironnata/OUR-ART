//
//  MyExhibitionViewModel.swift
//  OurArt
//
//  Created by Jongmo You on 10.05.24.
//

import Foundation
import Combine

@MainActor
final class MyExhibitionViewModel: ObservableObject {
    
    @Published private(set) var userMyExhibitions: [UserMyExhibition] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    func addListenerForMyExhibitions() {
        guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
        
//        UserManager.shared.addListenerForAllUserMyExhibitions(userId: authDataResult.uid) { [weak self] exhibitions in
//            self?.userMyExhibitions = exhibitions
//        }
        
        UserManager.shared.addListenerForAllUserMyExhibitions(userId: authDataResult.uid)
            .sink { complition in
                
            } receiveValue: { [weak self] exhibitions in
                self?.userMyExhibitions = exhibitions
            }
            .store(in: &cancellables)

    }
    
//    func getMyExhibitions() {
//        Task {
//            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
//            var userMyExhibitions = try await UserManager.shared.getAllMyExhibitions(userId: authDataResult.uid)
//
//            // 최신순 정렬 nil은 맨 나중으로 보내기
//            userMyExhibitions.sort(by: { (exhibition1, exhibition2) -> Bool in
//                let date1 = exhibition1.dateFrom ?? .distantPast
//                let date2 = exhibition2.dateFrom ?? .distantPast
//                return date1 > date2
//            })
//
//            self.userMyExhibitions = userMyExhibitions
//        }
//    }
    
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
        }
    }
}
