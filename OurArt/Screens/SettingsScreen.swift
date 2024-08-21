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
    
    @State private var isZoomed = false
    @State private var currentImage: Image? = nil
    
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var profileVM = ProfileViewModel()
    
    @Binding var showSignInView: Bool
    
    
    // MARK: - BODY
    
    var body: some View {
        ZStack {
            List {
                Section {
                    ProfileCellView(showSignInView: $showSignInView, isZoomed: $isZoomed, currentImage: $currentImage)
                    
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
                
                Section {
                    Button("Delete Account", role: .destructive) {
                        showDeleteAlert = true
                    }
                    .confirmationDialog("Are you sure you want to delete your account?", isPresented: $showDeleteAlert, titleVisibility: .visible) {
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
                        Text("Once you delete your account, all associated data will be lost forever. Please confirm if you wish to continue.")
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
                    Text("Version 1.0.0")
                        .font(.objectivityCaption)
                        .foregroundStyle(.secondAccent)
                    self.logoImageSettings()
                }
            }
        }
        .overlay(
            Group {
                if isZoomed, let image = currentImage {
                    FullScreenProfileImageView(isZoomed: $isZoomed, image: image)
                        .presentationBackground(.thinMaterial)
                }
            }
        )
        .toolbar(isZoomed ? .hidden : .visible, for: .tabBar, .navigationBar)
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
