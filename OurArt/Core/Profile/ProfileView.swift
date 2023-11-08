//
//  ProfileView.swift
//  OurArt
//
//  Created by Jongmo You on 19.10.23.
//

import SwiftUI
import PhotosUI
import Firebase

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    @Published var selectedImage: PhotosPickerItem? {
        didSet { Task { await loadImage(fromItem: selectedImage) } }
    }
    @Published var profileImage: Image?
    
    private var uiImage: UIImage?
    
    
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
    
    func loadImage(fromItem item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.uiImage = uiImage
        self.profileImage = Image(uiImage: uiImage)
    }
    
}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    let preferenceOptions: [String] = ["Aritst", "Audience"]
    
    @State private var nickname: String = ""
    @State private var showImagePicker = false
    @State private var photoItem: PhotosPickerItem?
    
    private func preferenceIsSelected(text: String) -> Bool {
        viewModel.user?.preferences?.contains(text) == true
    }
    
    
    // MARK: - BODY
    
    var body: some View {
        VStack {
            if let user = viewModel.user {
                
                Spacer()
                
                VStack(spacing: 10) {
                    ZStack {
                        if let image = viewModel.profileImage {
                            image
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(Color.accentColor)
                        }
                        
                        Button {
                            showImagePicker.toggle()
                        } label: {
                            Text("EDIT")
                        }
                        .modifier(SmallButtonModifier())
                        .offset(y: 30)
                        .photosPicker(isPresented: $showImagePicker, selection: $viewModel.selectedImage)
                    }
                    
                    // 닉네임 표시하는 방법! 가릿
                    // Text("\(user.nickname ?? "" )")
                    
                    TextField("Nickname...", text: $nickname)
                        .modifier(TextFieldModifier())
                        .padding(.top, 20)
                    
                    VStack {
                        Text("Choose who you are: \((user.preferences ?? []).joined(separator: " and "))")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            ForEach(preferenceOptions, id: \.self) { string in
                                Button(string) {
                                    if preferenceIsSelected(text: string) {
                                        viewModel.removeUserPreference(text: string)
                                    } else {
                                        viewModel.addUserPreference(text: string)
                                    }
                                }
                                .font(.headline)
                                .buttonStyle(.borderedProminent)
                                .tint(preferenceIsSelected(text: string) ? .accentColor : .secondary)
                            }
                        }
                    }
                }
                
                Divider()
                    .padding(.vertical, 10)
                
                Button {
                    viewModel.addNickname(text: nickname)
                } label: {
                    Text("Create the profile".uppercased())
                }
                .modifier(CommonButtonModifier())
                
            }
        }
        .overlay(alignment: .topTrailing) {
            NavigationLink {
                SettingsScreen(showSignInView: $showSignInView)
            } label: {
                Image(systemName: "gearshape.2")
            }
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 50)
        .task {
            try? await viewModel.loadCurrentUser()
        }
    }
}

#Preview {
    NavigationStack {
        RootView()
    }
}
