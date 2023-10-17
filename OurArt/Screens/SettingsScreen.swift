//
//  SettingsScreen.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI

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

struct SettingsScreen: View {
    
    @State var emailSheet = false
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            
            if viewModel.authProviders.contains(.email) {
                emailSection
            }
            
            if viewModel.authUser?.isAnonymous == true {
                anonymousSection
            }
            
            
            Button("Log Out", systemImage: "rectangle.portrait.and.arrow.right") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            }
            .foregroundStyle(Color.red)
        }
        .onAppear {
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
        }
        
    }
}

#Preview {
        SettingsScreen(showSignInView: .constant(false))
}




extension SettingsScreen {
    private var emailSection: some View {
        
        Section {
            Button("Reset Password", systemImage: "arrow.counterclockwise") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("PASSWORD RESET!")
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    private var anonymousSection: some View {
        
        Section {
            Button("Link Apple Account", systemImage: "apple.logo") {
                Task {
                    do {
                        try await viewModel.linkAppleAccount()
                        print("APPLE LINKED!")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Link Google Account", systemImage: "g.circle") {
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("GOOGLE LINKED!")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Link E-mail Account", systemImage: "envelope") {
                emailSheet = true
            }
            .sheet(isPresented: $emailSheet) {
                SignInEmailView(showSignInView: $showSignInView)
            }
        } header: {
            Text("Create Account")
        }
    }
}
