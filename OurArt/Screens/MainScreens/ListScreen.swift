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
    
    func loadCurrentExhibition(id: String) async throws {
//        guard let exhibitionId = exhibition?.id else { print("Current exhibition ID is nil.")
//            return
//        }
        self.exhibition = try await ExhibitionManager.shared.getExhibition(id: id)
    }
    
    func createExhibition(exhibition: Exhibition) async throws {
        print(exhibition)
        try await ExhibitionManager.shared.createExhibition(exhibition: exhibition)
    }
    
    
    // MARK: - POSTER IMAGE
    
    func savePosterImage(item: PhotosPickerItem) {
        Task {
                do {
                    // exhibition이 nil이 아닌지 확인
                    guard let exhibition = exhibition else {
                        print("전시가 nil입니다.")
                        return
                    }

                    // PhotosPickerItem에서 이미지 데이터 로드
                    guard let data = try await item.loadTransferable(type: Data.self) else {
                        print("이미지 데이터 로드 실패.")
                        return
                    }

                    // Storage에 포스터 이미지 저장
                    let (path, name) = try await StorageManager.shared.savePoster(data: data, exhibitionId: exhibition.id)
                    print("성공! 이미지가 Storage에 저장되었습니다. 경로: \(path), 이름: \(name)")

                    // Storage에 저장된 이미지의 URL 가져오기
                    let url = try await StorageManager.shared.getUrlForImage(path: path)

                    // Firestore 문서를 이미지 URL로 업데이트
                    try await ExhibitionManager.shared.updateUserPosterImagePath(exhibitionId: exhibition.id, path: path, url: url.absoluteString)
                    print("Firestore 문서가 이미지 URL로 업데이트되었습니다.")
                } catch {
                    // 오류 처리
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
    
}

struct ListScreen: View {
    
    @StateObject private var viewModel = ExhibitionViewModel()
    
    var body: some View {
       // print(viewModel.exhibitions.map { $0.id })

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
