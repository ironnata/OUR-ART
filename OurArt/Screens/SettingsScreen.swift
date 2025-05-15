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
    @StateObject private var profileVM = ProfileViewModel()
    
    @Binding var showSignInView: Bool
    
    
    // MARK: - BODY
    
    var body: some View {
        ZStack {
            List {
                Section {
                    ProfileCellView(showSignInView: $showSignInView)
                    
                    if let preferences = profileVM.user?.preferences, preferences.contains("Artist") {
                        NavigationLink(destination: MyExhibitionsView().navigationBarBackButtonHidden()) {
                            HStack {
                                Image(systemName: "list.star")
                                Text("My Exhibitions")
                            }
                        }
                    }
                    
                } header: {
                    Text("Profile")
                }
                .sectionBackground()
                
                if viewModel.authProviders.contains(.email) {
                    emailSection
                        .sectionBackground()
                }
                
                if viewModel.authUser?.isAnonymous == true {
                    anonymousSection
                        .sectionBackground()
                }
                
//                /////////// 이 여백 구간은 나중에 써먹을지 아닐지 모름 ///////////
//                Section {
//                    Color.background0.frame(height: 120)
//                        .sectionBackground()
//                        .listRowSeparator(.hidden)
//                }
                
                if profileVM.user?.isAnonymous == false {
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
                        .sectionBackground()
                        .foregroundStyle(Color.secondAccent)
                    } header: {
                        Text("Log Out")
                    }
                }
                
                Section {
                    Button("Delete Account", role: .destructive) {
                        showDeleteAlert = true
                    }
                    .confirmationDialog("Final Step", isPresented: $showDeleteAlert, titleVisibility: .visible) {
                        Button("Delete", role: .destructive) {
                            Task {
                                do {
                                    try await viewModel.deleteAccount()
                                    try await profileVM.deleteUser()
                                    print("User successfully deleted")
                                    showSignInView = true
                                } catch {
                                    print(error)
                                }
                            }
                        }
                    } message: {
                        Text("Heads up! Deleting your account will wipe all your data and can’t be undone. Still want to go ahead?")
                    }
                    .sectionBackground()
                } header: {
                    Text("Delete Account")
                }
                
            }
            .toolbarBackground()
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .onAppear {
                viewModel.loadAuthProviders()
                viewModel.loadAuthUser()
            }
            .task {
                try? await profileVM.loadCurrentUser()
            }
            .viewBackground()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Settings")
                    .font(.objectivityTitle)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Text("1.0.0")
                        .font(.objectivityCaption)
                        .foregroundStyle(.secondAccent)
                    self.logoImageSettings()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsScreen(showSignInView: .constant(false))
    }
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
            HStack {
                if #available(iOS 18.0, *) {
                    Image(systemName: "exclamationmark.brakesignal")
                        .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 2.0)))
                        .symbolRenderingMode(.palette)
                } else {
                    Image(systemName: "exclamationmark.brakesignal")
                }
                Text("Just browsing? All good. If you’re here to share your own work, sign up to get started!")
                    .font(.objectivityFootnote)
                    .foregroundStyle(.secondary)
            }
            .padding(6)
            
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
                .interactiveDismissDisabled(true)
            }
            
        } header: {
            Text("Create Account")
        }
    }
}
