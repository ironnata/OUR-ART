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
    @Published private(set) var myExhibition: UserMyExhibition?
    @Published var exhibition: Exhibition?
    
    private var cancellables = Set<AnyCancellable>()
    
    func addListenerForMyExhibitions() {
        guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
        
//        UserManager.shared.addListenerForAllUserMyExhibitions(userId: authDataResult.uid) { [weak self] exhibitions in
//            self?.userMyExhibitions = exhibitions
//        }
        
        UserManager.shared.addListenerForAllUserMyExhibitions(userId: authDataResult.uid)
            .sink { complition in
                
            } receiveValue: { [weak self] exhibitions in
                let sortedExhibitions = exhibitions.sorted { (exhibition1, exhibition2) -> Bool in
                    let date1 = exhibition1.dateCreated // nil인 경우 미래 날짜로 처리하여 맨 뒤로 정렬
                    let date2 = exhibition2.dateCreated // nil인 경우 미래 날짜로 처리하여 맨 뒤로 정렬
                    return date1 > date2 // 내림차순 정렬
                }
                self?.userMyExhibitions = sortedExhibitions
            }
            .store(in: &cancellables)

    }
    
    func removeListenerForMyExhibitions() {
        UserManager.shared.removeListenerForAllUserMyExhibitions()
    }
    
    func loadMyExhibition(myExhibitionId: String) {
        Task {
            guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }

            let exhibition = try await UserManager.shared.getMyExhibition(userId: authDataResult.uid, myExhibitionId: myExhibitionId)
            DispatchQueue.main.async { [weak self] in
                self?.myExhibition = exhibition
            }
        }
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
    
    func deleteMyExhibition(myExhibitionId: String) {
        guard let myExhibition else { return }
        
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            
            try await UserManager.shared.removeMyExhibition(userId: authDataResult.uid, myExhibitionId: myExhibition.id)
            try await ExhibitionManager.shared.deleteExhibition(exhibitionId: myExhibition.exhibitionId)
            try? await StorageManager.shared.deleteExhibitionImageFolder(exhibitionId: myExhibition.exhibitionId)
//            if let path = myExhibition.posterImagePath {
//                try await StorageManager.shared.deleteImage(path: path)
//            }
        }
    }
}
