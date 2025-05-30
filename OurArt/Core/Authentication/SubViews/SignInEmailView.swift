//
//  SignInEmailView.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI

struct SignInEmailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                TextField("e-mail...", text: $viewModel.email)
                    .modifier(TextFieldModifier())
                    .textInputAutocapitalization(.never)
                
                SecureField("password...", text: $viewModel.password)
                    .modifier(TextFieldModifier())
                    .padding(.bottom, 30)
                
                Button {
                    Task {
                        do {
                            try await viewModel.signUp()
                            showSignInView = false
                            dismiss()
                            return
                        } catch {
                            print(error)
                        }
                        
                        do {
                            try await viewModel.signIn()
                            showSignInView = false
                            dismiss()
                            return
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("SIGN IN")
                        .modifier(CommonButtonModifier())
                }
                .padding(.bottom, 50)
            }
            .padding()
            .navigationTitle("Sign In with E-mail")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .onTapGesture {
                            dismiss()
                        }
                }
            }
        }
        .viewBackground()
    }
}

#Preview {
    SignInEmailView(showSignInView: .constant(false))
}
