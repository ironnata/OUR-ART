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
    @State private var wasImageUpdated = false
    @State private var showUpdateMessage = false
    
    @State private var isZoomed = false
    @State private var currentImage: Image? = nil
    
    let placeholderImage = Image(systemName: "person.circle.fill")
    
    var updateMessageBanner: some View {
        Text("Profile image successfully updated!")
            .font(.objectivityCallout)
            .foregroundColor(.accentButtonText)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(Color.accent.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .transition(.move(edge: .top).combined(with: .opacity))
    }
    
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
                            
                            VStack {
                                if let urlString = user.profileImagePathUrl, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .modifier(ProfileImageModifer())
                                            .onTapGesture {
                                                withAnimation {
                                                    currentImage = image
                                                    isZoomed.toggle()
                                                }
                                            }
                                    } placeholder: {
                                        placeholderImage
                                            .resizable()
                                            .modifier(ProfileImageModifer())
                                            .foregroundStyle(Color.secondAccent)
                                            .onTapGesture {
                                                withAnimation {
                                                    currentImage = placeholderImage
                                                    isZoomed.toggle()
                                                }
                                            }
                                    }
                                } else {
                                    placeholderImage
                                        .resizable()
                                        .modifier(ProfileImageModifer())
                                        .foregroundStyle(Color.secondAccent)
                                        .onTapGesture {
                                            withAnimation {
                                                currentImage = placeholderImage
                                                isZoomed.toggle()
                                            }
                                        }
                                }
                                
                                Button {
                                    withAnimation {
                                        showImageEditView.toggle()
                                    }
                                } label: {
                                    Text("EDIT")
                                }
                                .modifier(SmallButtonModifier())
                                .padding(.top, 10)
                            }
                            .padding(.bottom, 20)
                            
                            VStack {
                                TextField(user.nickname ?? "Nickname...", text: $nickname)
                                    .modifier(TextFieldModifier())
                                    .padding(.bottom, 20)
                                
                                if user.isAnonymous == false {
                                    HStack {
                                        Text("I'm an \(user.preferences?.isEmpty == false ? user.preferences!.joined(separator: ", ") : "Audience")")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.secondary)
                                        
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
                            .padding(.horizontal, 10)
                        }
                        
                        Divider()
                            .padding(.vertical, 10)
                        
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
                    if wasImageUpdated {
                        withAnimation(.spring(response: 0.3)) {
                            showUpdateMessage = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.spring(response: 0.3)) {
                                showUpdateMessage = false
                                wasImageUpdated = false
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            Task {
                                try? await viewModel.loadCurrentUser()
                            }
                        }
                    }
                }) {
                    ProfileImageEditView(showImageEditview: $showImageEditView, wasImageUpdated: $wasImageUpdated, showSignInView: $showSignInView)
                        .presentationDetents([.height(200)])
                        .presentationBackground(.thinMaterial)
                }
                
                if showUpdateMessage {
                    VStack {
                        updateMessageBanner
                        Spacer()
                    }
                    .padding(.top, 100)
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
        .overlay(
            Group {
                if isZoomed, let image = currentImage {
                    FullScreenProfileImageView(isZoomed: $isZoomed, image: image)
                        .toolbar(isZoomed ? .hidden : .automatic, for: .navigationBar)
                }
            }
        )
    }
}

#Preview {
    ProfileEditView(showSignInView: .constant(true))
}
