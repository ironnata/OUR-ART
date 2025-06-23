//
//  SettignsViewModel.swift
//  OurArt
//
//  Created by Jongmo You on 19.10.23.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil
    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func deleteAccount() async throws {
        guard let authUser = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
        
        let myExhibitions = try await UserManager.shared.getAllMyExhibitions(userId: authUser.uid)
        
        for myExhibition in myExhibitions {
            try? await UserManager.shared.removeMyExhibition(userId: authUser.uid, myExhibitionId: myExhibition.id)
            try? await StorageManager.shared.deleteExhibitionImageFolder(exhibitionId: myExhibition.exhibitionId)
            try? await ExhibitionManager.shared.deleteExhibition(exhibitionId: myExhibition.exhibitionId)
        }
        
        try await UserManager.shared.deleteUser(userId: authUser.uid)
        try await AuthenticationManager.shared.delete()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func linkAppleAccount() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        self.authUser = try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
    }
    
    func linkGoogleAccount() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        self.authUser = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }
//  내가 사용하지 않을 기능
//    func linkEmailAccount() async throws {
//        let email = "랜덤 이메일 주소"
//        let password = "랜덤 패스워드"
//        self.authUser = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
//    }
}
