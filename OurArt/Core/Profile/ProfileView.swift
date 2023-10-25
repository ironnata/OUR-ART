//
//  ProfileView.swift
//  OurArt
//
//  Created by Jongmo You on 19.10.23.
//

import SwiftUI

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
    
    private func preferenceIsSelected(text: String) -> Bool {
        viewModel.user?.preferences?.contains(text) == true
    }
    
    
    // MARK: - BODY
    
    var body: some View {
        List {
            if let user = viewModel.user {
                Text("UserID: \(user.userId)")
                
                if let isAnonymous = user.isAnonymous {
                    Text("Is Anonymous: \(isAnonymous.description.capitalized)")
                }
                
                VStack {
                    HStack {
                        TextField("Nickname...", text: $nickname)
                            .modifier(TextFieldModifier())
                        
                        Button {
                            viewModel.addNickname(text: nickname)
                        } label: {
                            Text("Save".uppercased())
                        }
                        .modifier(SmallButtonModifier())
                    }
                    
                }
                
                // Firestore Arrays 튜토리얼, 예시
                VStack {
                    Text("Choose who you are: \((user.preferences ?? []).joined(separator: " and "))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
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
        .overlay {
            NavigationLink {
                SettingsScreen(showSignInView: $showSignInView)
            } label: {
                Image(systemName: "gearshape.2")
            }
        }
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
