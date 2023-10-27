//
//  ProfileView.swift
//  OurArt
//
//  Created by Jongmo You on 19.10.23.
//

import SwiftUI
import PhotosUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
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
    
//    func fetchNickname(text: String) {
//        guard let user else { return }
//        
//        Task {
//            try await UserManager.shared.fetchNickname(userId: user.userId)
//            self.user = try await UserManager.shared.getUser(userId: user.userId)
//        }
//    }
//    
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
                        Image("account_8205962")
                            .resizable()
                        .frame(width: 100, height: 100)
                        
                        Button {
                            showImagePicker.toggle()
                        } label: {
                            Text("EDIT")
                        }
                        .modifier(SmallButtonModifier())
                        .offset(y: 20)
                        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
                    }
                    
                    TextField("Nickname...", text: $nickname)
                        .modifier(TextFieldModifier())
                    
                    Button {
                        viewModel.addNickname(text: nickname)
                    } label: {
                        Text("Save".uppercased())
                    }
                    .modifier(CommonButtonModifier())
                }
                
                Divider()
                    .padding(.vertical, 20)
                
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
        }
        .overlay(alignment: .topTrailing) {
            NavigationLink {
                SettingsScreen(showSignInView: $showSignInView)
                    .navigationBarBackButtonHidden(true)
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
