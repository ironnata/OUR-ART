//
//  SettingsScreen.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI

struct SettingsScreen: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var showEmailSheet = false
    @State private var showDeleteAlert = false
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    
    // MARK: - BODY
    
    var body: some View {
        List {
            
            if viewModel.authProviders.contains(.email) {
                emailSection
            }
            
            if viewModel.authUser?.isAnonymous == true {
                anonymousSection
            }
            
            
            Section {
                Button("Log Out", systemImage: "rectangle.portrait.and.arrow.right") {
                    Task {
                        do {
                            try viewModel.signOut()
                            showSignInView = true
                        } catch {
                            print(error)
                        }
                    }
                }
                .foregroundStyle(Color.secondary)
            } header: {
                Text("Log Out")
            }
            
            Section {
                Button("Delete Account", role: .destructive) {
                    showDeleteAlert = true
                }
                .confirmationDialog("Are you sure?", isPresented: $showDeleteAlert, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        Task {
                            do {
                                try await viewModel.deleteAccount()
                                showSignInView = true
                            } catch {
                                print(error)
                            }
                        }
                    }
                } message: {
                    Text("After you delete your account, all you uploaded is going to be deleted too.")
                }
            } header: {
                Text("Delete Account")
            }
            
        }
        .listStyle(.plain)
        .onAppear {
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
        }
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
}

#Preview {
        SettingsScreen(showSignInView: .constant(false))
}




extension SettingsScreen {
    private var emailSection: some View {
        
        Section {
            Button("Reset Password", systemImage: "arrow.counterclockwise") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("PASSWORD RESET!")
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    private var anonymousSection: some View {
        
        Section {
            Button("Link Apple Account", systemImage: "apple.logo") {
                Task {
                    do {
                        try await viewModel.linkAppleAccount()
                        print("APPLE LINKED!")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Link Google Account", systemImage: "g.circle") {
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("GOOGLE LINKED!")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Link E-mail Account", systemImage: "envelope") {
                showEmailSheet = true
            }
            // 시트 dismiss 후 익명 섹션 남아있는 부분 추후 업데이트 요망
            .sheet(isPresented: $showEmailSheet) {
                NavigationStack {
                    SignInEmailView(showSignInView: $showSignInView)
                }
            }
        } header: {
            Text("Create Account")
        }
    }
}
