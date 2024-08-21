//
//  ProfileEditView.swift
//  OurArt
//
//  Created by Jongmo You on 15.11.23.
//

import SwiftUI

struct ProfileEditView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    let preferenceOptions: [String] = ["Artist"]
    
    @State private var nickname: String = ""
    @State private var showInputAlert = false
    @State private var showImageEditView = false
    
    private func preferenceIsSelected(text: String) -> Bool {
        viewModel.user?.preferences?.contains(text) == true
    }
    
    
    // MARK: - BODY
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if let user = viewModel.user {
                        
                        Spacer()
                        
                        VStack(spacing: 10) {
                            
                            HStack(spacing: 30) {
                                ZStack {
                                    if let urlString = user.profileImagePathUrl, let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .modifier(ProfileImageModifer())
                                        } placeholder: {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .modifier(ProfileImageModifer())
                                                .foregroundStyle(Color.secondAccent)
                                        } 
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .modifier(ProfileImageModifer())
                                            .foregroundStyle(Color.secondAccent)
                                    }
                                    
                                    Button {
                                        withAnimation {
                                            showImageEditView.toggle()
                                        }
                                    } label: {
                                        Text("EDIT")
                                    }
                                    .modifier(SmallButtonModifier())
                                    .offset(y: 30)
                                }
                                
                                TextField(user.nickname ?? "Nickname...", text: $nickname)
                                    .modifier(TextFieldModifier())
                                    .padding(.top, 20)
                            }
                            .padding(.horizontal, 10)
                            
                            
                            VStack {
                                Text("I'm an \(user.preferences?.isEmpty == false ? user.preferences!.joined(separator: ", ") : "Audience")")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.secondary)
                                
                                HStack {
                                    ForEach(preferenceOptions, id: \.self) { string in
                                        Button(string) {
                                            if preferenceIsSelected(text: string) {
                                                viewModel.removeUserPreference(text: string)
                                            } else {
                                                viewModel.addUserPreference(text: string)
                                            }
                                        }
                                        .font(.objectivityBody)
                                        .buttonStyle(.borderedProminent)
                                        .tint(preferenceIsSelected(text: string) ? .accentColor : .secondary) // secondary 색상고민좀
                                        .foregroundStyle(Color.accentButtonText)
                                    }
                                }
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 20)
                        
                        Button {
                            if nickname.isEmpty {
                                dismiss()
                            } else {
                                viewModel.addNickname(text: nickname)
                                dismiss()
                            }
                            
                        } label: {
                            Text("Done".uppercased())
                        }
                        .modifier(CommonButtonModifier())
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 50)
                .sheet(isPresented: $showImageEditView, onDismiss: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        Task {
                            try? await viewModel.loadCurrentUser()
                        }
                    }
                }) {
                    ProfileImageEditView(showImageEditview: $showImageEditView, showSignInView: $showSignInView)
                        .presentationDetents([.height(200)])
                        .presentationBackground(.thinMaterial)
                }
            }
            .viewBackground()
        }
        .task {
            try? await viewModel.loadCurrentUser()
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
    ProfileEditView(showSignInView: .constant(true))
}
