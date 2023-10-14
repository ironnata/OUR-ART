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
    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
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
}

struct SettingsScreen: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            
            if viewModel.authProviders.contains(.email) {
                emailSection
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
}
