//
//  ListScreen.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI
import PhotosUI

@MainActor
final class ExhibitionViewModel: ObservableObject {
    
    @Published private(set) var exhibitions: [Exhibition] = []
    @Published private(set) var exhibition: Exhibition? = nil
    
    func getAllExhibitions() async throws {
        self.exhibitions = try await ExhibitionManager.shared.getAllExhibitions()
    }
    
    func createExhibition(exhibition: Exhibition) async throws {
        try await ExhibitionManager.shared.createExhibition(exhibition: exhibition)
    }
    
    func updateExhibition(exhibitionId: String) async throws {
        try await ExhibitionManager.shared.updateExhibition(exhibitionId: exhibitionId)
    }
    
    // MARK: - POSTER IMAGE
    
    func savePosterImage(item: PhotosPickerItem) {
        Task {
            guard let exhibition = self.exhibition else { return }
            
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            let (path, name) = try await StorageManager.shared.savePoster(data: data, exhibitionId: exhibition.id)
            print("SUCCESS!")
            print(path)
            print(name)
            
            let url = try await StorageManager.shared.getUrlForImage(path: path)
            try await ExhibitionManager.shared.updateUserPosterImagePath(exhibitionId: exhibition.id, path: path, url: url.absoluteString)
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
    
}

struct ListScreen: View {
    
    @StateObject private var viewModel = ExhibitionViewModel()
    
    var body: some View {
        
        List {
            ForEach(viewModel.exhibitions) { exhibition in
                NavigationLink(destination: ExhibitionDetailView(exhibition: exhibition)) {
                    ExhibitionCellView(exhibition: exhibition)
                }
            }
            .listRowSeparator(.hidden)
        }
        .task {
            try? await viewModel.getAllExhibitions()
        }
        .listStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ListScreen()
    }
}
