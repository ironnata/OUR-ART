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
    
    let signInAppleHelper = SignInAppleHelper()
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }
    
    func signInApple() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
    }
}



// MARK: - BODY

struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        
        VStack {
            Spacer()
            
            // APPLE Dev Program 가입 후 활성화!!!!!
            Button(action: {
                Task {
                    do {
                        try await viewModel.signInApple()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                    .allowsHitTesting(false)
            })
                .modifier(ButtonModifier())
            
            
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
