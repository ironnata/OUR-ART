//
//  SignInEmailView.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI

@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        try await AuthenticationManager.shared.creatUser(email: email, password: password)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}

struct SignInEmailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField("e-mail...", text: $viewModel.email)
                .padding()
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            SecureField("password...", text: $viewModel.password)
                .padding()
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 30)
            
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        self.presentationMode.wrappedValue.dismiss()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                    
                    do {
                        try await viewModel.signIn()
                        self.presentationMode.wrappedValue.dismiss()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Sign In")
                    .modifier(ButtonModifier())
            }
            .padding(.bottom, 50)
        }
        .padding()
        .navigationTitle("Sign In with E-mail")
    }
}

#Preview {
    SignInEmailView(showSignInView: .constant(false))
}
