//
//  AuthenticationView.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        
        VStack(spacing: 10) {
            Spacer()
            
            // *** APPLE Dev Program 가입 후 활성화!!!!!
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
                .modifier(AuthButtonModifier())
            
            
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
            .modifier(AuthButtonModifier())
            
            
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
                    .navigationBarBackButtonHidden(true)
            } label: {
                HStack {
                    Image(systemName: "envelope")
                    Text("Sign in with E-mail")
                }
                .modifier(AuthButtonModifier())
            }
            
            
            Button {
                Task {
                    do {
                        try await viewModel.signInAnonymous()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "eyeglasses")
                    Text("Sign in Anonymously")
                }
                .modifier(AuthButtonModifier())
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
