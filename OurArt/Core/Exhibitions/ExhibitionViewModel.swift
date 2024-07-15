//
//  ExhibitionViewModel.swift
//  OurArt
//
//  Created by Jongmo You on 10.05.24.
//

import Foundation
import SwiftUI
import PhotosUI
import FirebaseFirestore

@MainActor
final class ExhibitionViewModel: ObservableObject {
    
    @Published private(set) var exhibitions: [Exhibition] = []
    @Published private(set) var exhibition: Exhibition? = nil
    @Published var selectedFilter: FilterOption? = nil
    private var lastDocument: DocumentSnapshot? = nil
//    @Published var selectedCategory: CategoryOption? = nil // CATEGORY 추가 시 사용
    
    enum FilterOption: String, CaseIterable {
        case noFilter = "No Filter"
        case newest = "Most recent at the top"
        case oldest = "Oldest at the top"
        
        var dateDescending: Bool? {
            switch self {
            case .noFilter: return nil
            case .newest: return true
            case .oldest: return false
            }
        }
        
        var icon: String? {
            switch self {
            case .noFilter: return "line.3.horizontal.decrease.circle"
            case .newest: return "arrow.down.to.line"
            case .oldest: return "arrow.up.to.line"
            }
        }
    }
    
    func filterSelected(option: FilterOption) async throws {
        self.selectedFilter = option
        self.exhibitions = []
        self.lastDocument = nil
        self.getExhibitions()
        
//        switch option {
//        case .noFilter:
//            self.exhibitions = try await ExhibitionManager.shared.getAllExhibitions()
//        case .newest:
//            self.exhibitions = try await ExhibitionManager.shared.getAllExhibitionsSortedByDate(descending: true)
//        case .oldest:
//            self.exhibitions = try await ExhibitionManager.shared.getAllExhibitionsSortedByDate(descending: false)
//        }
    }
    
    // CATEGORY 추가 시 사용
//    enum CategoryOption: String, CaseIterable {
//        case noCategory
//        case ex1
//        case ex2
//        case ex3
//    }
    
    // CATEGORY 추가 시 사용
//    func categorySelected(option: CategoryOption) async throws {
//        self.selectedCategory = option // CATEGORY 추가 시 사용
//        self.getProducts() // CATEGORY 추가 시 사용
//
//        switch option {
//        case .noCategory:
//            self.exhibitions = try await ExhibitionManager.shared.getAllExhibitions()
//        case .ex1, .ex2, .ex3:
//            self.exhibitions = try await ExhibitionManager.shared.getAllExhibitionsForCategory(category: option.rawValue)
//        }
//    }
    
    // CATEGORY 추가 시 사용
//    func getProducts() {
//        Task {
//            self.exhibitions = try await ExhibitionManager.shared.getAllExhibitions(dateDescending: selectedFilter?.dateDescending, forCategory: selectedCategory?.rawValue)
//        }
//    }
    
//    func getAllExhibitions() async throws {
//        self.exhibitions = try await ExhibitionManager.shared.getAllExhibitions()
//    }
    
    // With Pagination
    func getExhibitions() {
        Task {
            let (newExhibitions, lastDocument) = try await ExhibitionManager.shared.getExhibitions(dateDescending: selectedFilter?.dateDescending, count: 5, lastDocument: lastDocument)
            
            self.exhibitions.append(contentsOf: newExhibitions)
            if let lastDocument {
                self.lastDocument = lastDocument
            }
        }
    }
    
    // 전시 수 세는 func
//    func getAllExhibitionsCount() {
//        Task {
//            let count = try await ExhibitionManager.shared.getAllExhibitionsCount()
//            print("All Exhibition Count: \(count)")
//        }
//    }
    
    func createExhibition(exhibition: Exhibition) async throws {
        try await ExhibitionManager.shared.createExhibition(exhibition: exhibition)
    }
    
    func loadCurrentExhibition(id: String) async throws {
        self.exhibition = try await ExhibitionManager.shared.getExhibition(id: id)
    }
    
    // addTitle func
    func addTitle(text: String) async throws {
        guard let exhibition else { return }
        
        Task {
            try await ExhibitionManager.shared.addTitle(exhibitionId: exhibition.id, title: text)
            self.exhibition = try await ExhibitionManager.shared.getExhibition(id: exhibition.id)
        }
    }
    
    // addArtist func
    func addArtist(text: String) async throws {
        guard let exhibition else { return }
        
        Task {
            try await ExhibitionManager.shared.addArtist(exhibitionId: exhibition.id, artist: text)
            self.exhibition = try await ExhibitionManager.shared.getExhibition(id: exhibition.id)
        }
    }
    
    // addDate func
    func addDate(dateFrom: Date, dateTo: Date) async throws {
        guard let exhibition else { return }
        
        Task {
            try await ExhibitionManager.shared.addDate(exhibitionId: exhibition.id, dateFrom: dateFrom, dateTo: dateTo)
            self.exhibition = try await ExhibitionManager.shared.getExhibition(id: exhibition.id)
        }
    }
    
    // addAddress func
    func addAddress(text: String) async throws {
        guard let exhibition else { return }
        
        Task {
            try await ExhibitionManager.shared.addAddress(exhibitionId: exhibition.id, address: text)
            self.exhibition = try await ExhibitionManager.shared.getExhibition(id: exhibition.id)
        }
    }
    
    // addOpeningHours func
    func addOpeningHours(openingHoursFrom: Date, openingHoursTo: Date) async throws {
        guard let exhibition else { return }
        
        Task {
            try await ExhibitionManager.shared.addOpeningHours(exhibitionId: exhibition.id, openingHoursFrom: openingHoursFrom, openingHoursTo: openingHoursTo)
            self.exhibition = try await ExhibitionManager.shared.getExhibition(id: exhibition.id)
        }
    }
    
    // addClosingDays func
    func addClosingDays(text: String) {
        guard let exhibition else { return }
        
        Task {
            try await ExhibitionManager.shared.addClosingDaysPreference(exhibitionId: exhibition.id, closingDays: text)
            self.exhibition = try await ExhibitionManager.shared.getExhibition(id: exhibition.id)
        }
    }
    
    // removeClosingDays func
    func removeClosingDays(text: String) {
        guard let exhibition else { return }
        
        Task {
            try await ExhibitionManager.shared.removeClosingDaysPreference(exhibitionId: exhibition.id, closingDays: text)
            self.exhibition = try await ExhibitionManager.shared.getExhibition(id: exhibition.id)
        }
    }
    
    // addDiscription func
    func addDescription(text: String) async throws {
        guard let exhibition else { return }
        
        Task {
            try await ExhibitionManager.shared.addDescription(exhibitionId: exhibition.id, description: text)
            self.exhibition = try await ExhibitionManager.shared.getExhibition(id: exhibition.id)
        }
    }
    
    func deleteExhibition() async throws {
        guard let exhibition else { return }
        
        try await ExhibitionManager.shared.deleteExhibition(exhibitionId: exhibition.id)
        
        if let path = exhibition.posterImagePath {
            try await StorageManager.shared.deleteImage(path: path)
            print("The Exhibition is deleted")
        }
        
    }
    
    
    // MARK: - POSTER IMAGE
    
    func savePosterImage(item: PhotosPickerItem) {
        Task {
            do {
                guard let exhibition = exhibition else { return }
                
                guard let data = try await item.loadTransferable(type: Data.self) else { return }
                let (path, name) = try await StorageManager.shared.savePoster(data: data, exhibitionId: exhibition.id)
                print("SUCCESS!")
                print(path)
                print(name)
                
                let url = try await StorageManager.shared.getUrlForImage(path: path)
                try await ExhibitionManager.shared.updateUserPosterImagePath(exhibitionId: exhibition.id, path: path, url: url.absoluteString)
            } catch {
                print("포스터 이미지 저장 중 오류 발생: \(error)")
            }
        }
    }
    
//    func deleteProfileImage() {
//        guard let user, let path = user.profileImagePath else { return }
//
//        Task {
//            try await StorageManager.shared.deleteImage(path: path)
//            try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: nil, url: nil)
//        }
//    }
//
//    func loadImage(fromItem item: PhotosPickerItem?) async {
//        guard let item = item else { return }
//
//        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
//        guard let uiImage = UIImage(data: data) else { return }
//        self.uiImage = uiImage
//        self.profileImage = Image(uiImage: uiImage)
//    }
    
    // MARK: - MY EXHIBITIONS
    
    func addUserMyExhibition(exhibitionId: String) {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try? await UserManager.shared.addMyExhibition(userId: authDataResult.uid, exhibitionId: exhibitionId)
        }
    }
    
    
}
