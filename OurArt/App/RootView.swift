//
//  RootView.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    @State private var userNickname: String? = nil
    
    var body: some View {
        ZStack {
            if !showSignInView {
                NavigationStack {
                    if userNickname != nil {
                        ContentView(showSignInView: $showSignInView)
                    } else {
                        ProfileView(showSignInView: $showSignInView)
                    }
                }
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
            
            if let userId = authUser?.uid {
                Task {
                    do {
                        let user = try await UserManager.shared.getUser(userId: userId)
                        self.userNickname = user.nickname
                    } catch {
                        print("Error fetching user profile: \(error)")
                    }
                }
                
            }
        }
        .viewBackground()
        .fullScreenCover(isPresented: $showSignInView, onDismiss: {
            // 풀스크린커버가 닫힐 때 사용자 정보 다시 확인
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            if let userId = authUser?.uid {
                Task {
                    do {
                        let user = try await UserManager.shared.getUser(userId: userId)
                        self.userNickname = user.nickname
                    } catch {
                        print("Error fetching user profile: \(error)")
                    }
                }
            }
        }) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}

#Preview {
    RootView()
}
