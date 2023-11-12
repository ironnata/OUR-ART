//
//  ProfileViewModel.swift
//  OurArt
//
//  Created by Jongmo You on 10.11.23.
//

import Foundation
import SwiftUI
import PhotosUI


@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    @Published var selectedImage: PhotosPickerItem? {
        didSet { Task { await loadImage(fromItem: selectedImage) } }
    }
    @Published var profileImage: Image?
    
    private var uiImage: UIImage?
    
    
    // MARK: - USER
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func addUserPreference(text: String) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.addUserPreference(userId: user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeUserPreference(text: String) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.removeUserPreference(userId: user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addNickname(text: String) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.addNickname(userId: user.userId, nickname: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    // MARK: - IMAGE
    
    func saveProfileImage(item: PhotosPickerItem) {
        guard let user else { return }
        
        Task {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            let (path, name) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
            print("SUCCESS!")
            print(path)
            print(name)
            
            let url = try await StorageManager.shared.getUrlForImage(path: path)
            try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: url.absoluteString)
        }
    }
    
    func loadImage(fromItem item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.uiImage = uiImage
        self.profileImage = Image(uiImage: uiImage)
    }
    
}
