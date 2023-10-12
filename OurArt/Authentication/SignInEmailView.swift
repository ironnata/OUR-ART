//
//  SignInEmailView.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI

final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
}

struct SignInEmailView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()
    
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
                
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundStyle(Color.white)
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .background(Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .padding(.bottom, 50)
        }
        .padding()
        .navigationTitle("Sign In with E-mail")
    }
}

#Preview {
    SignInEmailView()
}
