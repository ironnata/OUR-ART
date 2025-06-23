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
        
        ZStack {
            VStack(spacing: 10) {
                Spacer()
                
                self.logoImageAuth()
                
                Text("Dot's where art connects".uppercased())
                
                Spacer()
                
                // MARK: - APPLE
                // *** APPLE Dev Program 가입 후 활성화!!!!! ***
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
//                    SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
//                        .allowsHitTesting(false)
                    HStack {
                        Image(systemName: "apple.logo")
                        Text("Sign in with Apple")
                    }
                })
                .modifier(AuthButtonModifier())
                
                // MARK: - GOOGLE
                Button{
                    Task {
                        do {
                            try await viewModel.signInGoogle()
                            showSignInView = false
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    HStack {
                        Image("google-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("Sign in with Google")
                    }
                }
                .modifier(AuthButtonModifier())
                
                // MARK: - E-MAIL
                NavigationLink {
                    SignInEmailView(showSignInView: $showSignInView)
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack {
                        Image(systemName: "envelope")
                            .imageScale(.small)
                        Text("Sign in with E-mail")
                    }
                    .modifier(AuthButtonModifier())
                }
                
                // MARK: - ANONYMOUS
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
                            .imageScale(.small)
                        Text("Sign in Anonymously")
                    }
                    .modifier(AuthButtonModifier())
                }
                .padding(.bottom, 50)
                
            }
            .padding()
        }
        .viewBackground()
    }
}

#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(false))
    }
}
