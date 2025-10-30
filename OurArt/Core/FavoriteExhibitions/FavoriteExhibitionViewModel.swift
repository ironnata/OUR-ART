//
//  Untitled.swift
//  OurArt
//
//  Created by Jongmo You on 30.10.25.
//

import Foundation
import Combine

@MainActor
final class FavoriteExhibitionViewModel: ObservableObject {
    
    @Published private(set) var favExhibitions: [UserFavoriteExhibition] = []
    @Published private(set) var favExhibition: UserFavoriteExhibition?
    @Published private(set) var favOngoingOrUpcoming: [Exhibition] = []
    @Published private(set) var favPast: [Exhibition] = []
    
    @Published var exhibition: Exhibition?
    
    private var cancellables = Set<AnyCancellable>()
    
    func updateSections(with exhibitions: [Exhibition]) {
        // 내 my_exhibition → exhibitionId 집합
        let myIds = Set(favExhibitions.map { $0.exhibitionId })

        // 내가 가진 전시만 추출
        let mine = exhibitions.filter { myIds.contains($0.id) }

        let today = Calendar.current.startOfDay(for: Date())

        // 파티션
        let ongoing = mine.filter { exhibition in
            guard let to = exhibition.dateTo else { return true }
            return to >= today
        }
        let pastOnes = mine.filter { exhibition in
            guard let to = exhibition.dateTo else { return false }
            return to < today
        }

        // 정렬: Newest 고정
        let ongoingSorted = ongoing.sorted {
            ($0.dateFrom ?? .distantFuture) > ($1.dateFrom ?? .distantFuture)
        }
        let pastSorted = pastOnes.sorted {
            ($0.dateTo ?? .distantPast) > ($1.dateTo ?? .distantPast)
        }

        self.favOngoingOrUpcoming = ongoingSorted
        self.favPast = pastSorted
    }
    
    func addListenerForAllUserFavorites() {
        guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
        
//        UserManager.shared.addListenerForAllUserMyExhibitions(userId: authDataResult.uid) { [weak self] exhibitions in
//            self?.userMyExhibitions = exhibitions
//        }
        
        UserManager.shared.addListenerForAllUserFavorites(userId: authDataResult.uid)
            .sink { complition in
                
            } receiveValue: { [weak self] exhibitions in
                let sortedExhibitions = exhibitions.sorted { (exhibition1, exhibition2) -> Bool in
                    let date1 = exhibition1.dateCreated // nil인 경우 미래 날짜로 처리하여 맨 뒤로 정렬
                    let date2 = exhibition2.dateCreated // nil인 경우 미래 날짜로 처리하여 맨 뒤로 정렬
                    return date1 > date2 // 내림차순 정렬
                }
                self?.favExhibitions = sortedExhibitions
            }
            .store(in: &cancellables)

    }
    
    func removeListenerForAllUserFavorites() {
        UserManager.shared.removeListenerForAllUserFavorites()
    }
    
    func loadFavorite(favExhibitionId: String) {
        Task {
            guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }

            let exhibition = try await UserManager.shared.getFavorite(userId: authDataResult.uid, favExhibitionId: favExhibitionId)
            DispatchQueue.main.async { [weak self] in
                self?.favExhibition = exhibition
            }
        }
    }
    
    func deleteFavorite(favExhibitionId: String) async throws {
        guard let favExhibition else { return }
        
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            
            try await UserManager.shared.removeFavorite(userId: authDataResult.uid, favExhibitionId: favExhibitionId)
            try await ExhibitionManager.shared.deleteExhibition(exhibitionId: favExhibition.exhibitionId)
            try? await StorageManager.shared.deleteExhibitionImageFolder(exhibitionId: favExhibition.exhibitionId)
//            if let path = myExhibition.posterImagePath {
//                try await StorageManager.shared.deleteImage(path: path)
//            }
        }
    }
}
