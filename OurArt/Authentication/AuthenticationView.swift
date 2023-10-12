//
//  AuthenticationView.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        
        VStack {
            Spacer()
            
            NavigationLink {
                SignInEmailView()
            } label: {
                Text("Sign in with E-mail")
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
        .navigationTitle("Sign In")
    }
}

#Preview {
    NavigationStack {
        AuthenticationView()
    }
}
