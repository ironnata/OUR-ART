//
//  AuthenticationView.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }
}


struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        
        VStack {
            Spacer()
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel()) {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }
            .modifier(ButtonModifier())
            
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                HStack {
                    Image(systemName: "envelope")
                    Text("Sign in with E-mail")
                }
                .modifier(ButtonModifier())
            }
            .padding(.bottom, 50)
            
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(false))
    }
}
