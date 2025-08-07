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
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 4)
                }
                
                if viewModel.isLinkSent {
                    Text("이메일로 인증 링크를 보냈습니다. 이메일을 확인해주세요.")
                        .foregroundColor(.green)
                        .font(.caption)
                        .padding(.top, 4)
                }
                
                Button {
                    Task {
                        try await viewModel.signInWithEmailLink()
                    }
                } label: {
                    Text("이메일로 로그인 링크 받기")
                        .modifier(CommonButtonModifier())
                }
                .padding(.top, 30)
                .padding(.bottom, 50)
            }
            .padding()
            .navigationTitle("이메일로 로그인")
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
