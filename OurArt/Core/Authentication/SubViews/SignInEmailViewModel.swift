//
//  SignInEmailViewModel.swift
//  OurArt
//
//  Created by Jongmo You on 19.10.23.
//

import Foundation

@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var isLinkSent = false
    @Published var errorMessage: String?
    
    func signInWithEmailLink() async throws {
        guard !email.isEmpty else {
            errorMessage = "이메일을 입력해주세요."
            return
        }
        
        do {
            let authDataResult = try await AuthenticationManager.shared.signInWithEmailLink(email: email)
            let user = DBUser(auth: authDataResult)
            try await UserManager.shared.creatNewUser(user: user)
            isLinkSent = true
        } catch {
            errorMessage = "이메일 전송 중 오류가 발생했습니다: \(error.localizedDescription)"
        }
    }
    
    func handleEmailLink(_ link: String) async throws {
        do {
            let authDataResult = try await AuthenticationManager.shared.confirmSignInWithEmailLink(email: email, link: link)
            let user = DBUser(auth: authDataResult)
            try await UserManager.shared.creatNewUser(user: user)
        } catch {
            errorMessage = "이메일 링크 인증 중 오류가 발생했습니다: \(error.localizedDescription)"
        }
    }
}
