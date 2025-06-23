//
//  SettingsScreen.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI

struct SettingsScreen: View {
    
    @Environment(\.dismiss) var dismiss
    
    let version: String = "1.0.0"
    
    @State var showEmailSheet = false
    @State private var showDeleteAlert = false
    @State private var showLogoutAlert = false
    
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var profileVM = ProfileViewModel()
    
    @Binding var showSignInView: Bool
    
    
    // MARK: - BODY
    
    var body: some View {
        ZStack {
            List {
                Section {
                    ProfileCellView(showSignInView: $showSignInView)
                    
                    
                }
                .listRowSeparator(.hidden, edges: .top)
                .sectionBackground()
                
                if let preferences = profileVM.user?.preferences, preferences.contains("Artist") {
                    Section {
                        NavigationLink(destination: MyExhibitionsView().navigationBarBackButtonHidden()) {
                            HStack {
                                Image(systemName: "list.star")
                                    .frame(width: 24, alignment: .leading)
                                Text("My Exhibitions")
                            }
                        }
                    } header: {
                        Text("My Dots")
                            .font(.objectivityCallout)
                    }
                    .sectionBackground()
                }
                
                ////// PW 변경인 부분이라 아마 안쓸듯 /////
                if viewModel.authProviders.contains(.email) {
                    emailSection
                        .sectionBackground()
                }
                
                if viewModel.authUser?.isAnonymous == true {
                    anonymousSection
                        .sectionBackground()
                }
                
                ///// 여기는 일단 목업처럼 해둔거임 /////
                Section {
                    SettingsRow(icon: "info.circle", label: "About Dot")
                    // 여기 접속하면 앱과 개발자 정보 ex) 앱개발자 소개: 이름, email, 한마디... 예시> “Dot is an indie app made by one person who loves art & tech.” //
                    if profileVM.user?.isAnonymous == false {
                        SettingsRow(icon: "bubble.left.and.text.bubble.right", label: "Feedback")
                    }
                } header: {
                    Text("App Info")
                        .font(.objectivityCallout)
                }
                .sectionBackground()
                
                Section {
                    SettingsRow(icon: "lock.shield", label: "Privacy Policy")
                    SettingsRow(icon: "text.page", label: "Terms of Use")
                } header: {
                    Text("Legal")
                        .font(.objectivityCallout)
                }
                .sectionBackground()
                
                Section {
                    if profileVM.user?.isAnonymous == false {
                        Button {
                            showLogoutAlert = true
                        } label: {
                            SettingsRow(icon: "door.right.hand.open", label: "Log Out")
                        }
                        .confirmationDialog("Log Out", isPresented: $showLogoutAlert) {
                            Button("Log out") {
                                Task {
                                    do {
                                        try viewModel.signOut()
                                        showSignInView = true
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        } message: {
                            Text("No worries — you can sign back in whenever.")
                        }
                        .sectionBackground()
                        .foregroundStyle(Color.secondAccent)
                    }
                    
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "eyes")
                                .foregroundStyle(Color.secondAccent)
                                .frame(width: 24)
                            Text("Delete Account")
                        }
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
                    Text("Exit & Erase")
                        .font(.objectivityCallout)
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
                    Text(version)
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


struct SettingsRow: View {
    var icon: String
    var label: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
            Text(label)
        }
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
                Text("Liking what you see? Connect your account to share your own work")
                    .font(.objectivityFootnote)
                    .foregroundStyle(.secondary)
            }
            .padding(6)
            
            Button {
                Task {
                    do {
                        try await viewModel.linkAppleAccount()
                        print("APPLE LINKED!")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "apple.logo")
                        .frame(width: 18)
                        .padding(.trailing, 6)
                    Text("Apple")
                }
            }
            
            Button {
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("GOOGLE LINKED!")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                HStack(alignment: .center) {
                    Image("google-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .padding(.trailing, 6)
                    Text("Google")
                }
            }
            
            Button {
                showEmailSheet = true
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "envelope")
                        .frame(width: 18)
                        .padding(.trailing, 6)
                    Text("Email")
                }
            }
            // 시트 dismiss 후 익명 섹션 남아있는 부분 추후 업데이트 요망
            .sheet(isPresented: $showEmailSheet) {
                NavigationStack {
                    SignInEmailView(showSignInView: $showSignInView)
                }
                .interactiveDismissDisabled(true)
            }
            
        } header: {
            Text("Continue with")
                .font(.objectivityCallout)
        }
    }
}
