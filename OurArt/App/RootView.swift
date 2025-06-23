//
//  RootView.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    @State private var showWelcomeView: Bool = false
    
    var body: some View {
        ZStack {
            if !showSignInView {
                NavigationStack {
                    ZStack {
                        if showWelcomeView {
                            WelcomeView(showWelcomeView: $showWelcomeView)
                        } else {
                            ContentView(showSignInView: $showSignInView)
                        }
                    }
                }
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .viewBackground()
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
        .onChange(of: showSignInView) { _, newValue in
            if !newValue {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showWelcomeView = true
                }
            }
        }
    }
}

#Preview {
    RootView()
}
