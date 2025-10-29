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
    
    @Namespace private var fullPosterNS
    
    @State private var nickname: String = ""
    @State private var showInputAlert = false
    @State private var showImageEditView = false
    @State private var wasImageUpdated = false
    @State private var showUpdateMessage = false
    
    @State private var showEditNameView = false
    @State private var showEditPreferencesView = false
    
    @State private var isZoomed = false
    @State private var currentImage: Image? = nil
    
    let placeholderImage = Image(systemName: "person.circle.fill")
    
    
    // MARK: - BODY
    
    var body: some View {
        NavigationStack {
            if let user = viewModel.user {
                ZStack {
                    VStack {
                        
                        Spacer()
                        
                        VStack(spacing: 10) {
                            
                            Spacer()
                            
                            VStack {
                                if let urlString = user.profileImagePathUrl, let url = URL(string: urlString) {
                                    let gid = "profile-\(user.userId)"
                                    
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .modifier(ProfileImageModifer())
                                            .if(!isZoomed) { view in
                                                view.matchedGeometryEffect(id: gid, in: fullPosterNS)
                                            }
                                            .opacity(isZoomed ? 0 : 1)
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
                                    if user.profileImagePathUrl != nil {
                                        Text("EDIT")
                                    } else {
                                        Text("+")
                                            .padding(.horizontal, 10)
                                    }
                                }
                                .modifier(SmallButtonModifier())
                                .padding(.top, 10)
                            }
                            .padding(.bottom, 20)
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
                                let detents: Set<PresentationDetent> = (user.profileImagePathUrl == nil) ? [.height(170)] : [.height(200)]
                                
                                ProfileImageEditView(showImageEditview: $showImageEditView, wasImageUpdated: $wasImageUpdated, showSignInView: $showSignInView)
                                    .presentationDetents(detents)
                                    .presentationDragIndicator(.visible)
                                    .presentationBackground(.thinMaterial)
                            }
                            
                            Spacer()
                            
                            VStack {
                                ProfileRow(title: "Profilename", value: user.nickname ?? "")
                                    .onTapGesture {
                                        showEditNameView = true
                                    }
                                    .sheet(isPresented: $showEditNameView, onDismiss: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            Task {
                                                try? await viewModel.loadCurrentUser()
                                            }
                                        }
                                    }) {
                                        EditNicknameView(nickname: $nickname)
                                            .presentationDetents([.height(220)])
                                            .presentationDragIndicator(.visible)
                                            .presentationBackground(.thinMaterial)
                                        
                                    }
                                
                                if user.isAnonymous == false {
                                    ProfileRow(title: "You are...", value: (user.preferences?.isEmpty == false ? user.preferences!.joined(separator: ", ") : "Audience"))
                                        .onTapGesture {
                                            showEditPreferencesView = true
                                        }
                                        .sheet(isPresented: $showEditPreferencesView, onDismiss: {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                Task {
                                                    try? await viewModel.loadCurrentUser()
                                                }
                                            }
                                        }) {
                                            EditPreferencesView()
                                                .presentationDetents([.height(160)])
                                                .presentationDragIndicator(.visible)
                                                .presentationBackground(.thinMaterial)
                                        }
//                                    HStack {
//                                        Text("I'm an \(user.preferences?.isEmpty == false ? user.preferences!.joined(separator: ", ") : "Audience")")
//                                            .frame(maxWidth: .infinity, alignment: .leading)
//                                            .foregroundStyle(.secondary)
//                                        
//                                        ForEach(preferenceOptions, id: \.self) { string in
//                                            Button(string) {
//                                                if preferenceIsSelected(text: string) {
//                                                    viewModel.removeUserPreference(text: string)
//                                                } else {
//                                                    viewModel.addUserPreference(text: string)
//                                                }
//                                            }
//                                            .font(.objectivityBody)
//                                            .buttonStyle(.borderedProminent)
//                                            .tint(preferenceIsSelected(text: string) ? .accentColor : .secondary) // secondary 색상고민좀
//                                            .foregroundStyle(Color.accentButtonText)
//                                        }
//                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                            
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 50)
                .toolbar(isZoomed ? .hidden : .automatic, for: .navigationBar)
                .viewBackground()
                .toolbar {
                    ToolbarBackButton()
                }
                .overlay(
                    Group {
                        if isZoomed, let image = currentImage {
                            FullScreenProfileImageView(
                                isZoomed: $isZoomed,
                                image: image,
                                posterNamespace: fullPosterNS,
                                geometryId: "profile-\(user.userId)"
                            )
                            .transition(.identity) // matchedGeometryEffect와 충돌 방지
                            .zIndex(1)
                        }
                    }
                )
                
                if showUpdateMessage {
                    VStack {
                        BannerMessage(text: "Profile image has successfully updated!")
                        Spacer()
                    }
                    .padding(.top, 100)
                }
                
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
    }
}

#Preview {
    ProfileEditView(showSignInView: .constant(true))
}

struct ProfileRow: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.objectivityFootnote)
                .foregroundStyle(Color.secondAccent)
            Text(value)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.redacted)
        .clipShape(.rect(cornerRadius: 8))
    }
}


struct EditNicknameView : View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = ProfileViewModel()
    
    @Binding var nickname: String
    
    var body: some View {
        ZStack {
            VStack {
                if let user = viewModel.user {
                    HStack(alignment: .center) {
                        Text("Profilename")
                        
                        Spacer()
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                        }
                    }
                    .padding(.vertical, 10)
                    
                    TextField(user.nickname ?? "Nickname...", text: $nickname)
                        .modifier(TextFieldModifier())
                    
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
                        Text("Save".uppercased())
                    }
                    .modifier(CommonButtonModifier())
                }
            }
            .padding()
        }
        .viewBackground()
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .onDisappear {
            nickname = ""
        }
    }
}


struct EditPreferencesView: View {
    @Environment(\.dismiss) var dismiss
        
    let preferenceOptions = ["Artist", "Audience"]
    
    @StateObject private var viewModel = ProfileViewModel()
    
    private func preferenceIsSelected(text: String) -> Bool {
        viewModel.user?.preferences?.contains(text) == true
    }
    
    var body: some View {
        ZStack {
            VStack {
                if let user = viewModel.user {
                    HStack(alignment: .center) {
                        Text("Select your preferences")
                        
                        Spacer()
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                        }
                    }
                    .padding(.vertical, 10)
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    HStack {
                        ForEach(preferenceOptions, id: \.self) { option in
                            Button {
                                if preferenceIsSelected(text: option) {
                                    dismiss()
                                } else {
                                    if let currentPrefs = user.preferences {
                                        for pref in currentPrefs {
                                            viewModel.removeUserPreference(text: pref)
                                        }
                                    }
                                    viewModel.addUserPreference(text: option)
                                    dismiss()
                                }
                            } label: {
                                Text(option)
                                    .frame(maxWidth: .infinity, minHeight: 30)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(preferenceIsSelected(text: option) ? Color.accentColor : Color.secondary)
                            .foregroundStyle(Color.accentButtonText)
                        }
                    }
                }
            }
            .padding()
        }
        .viewBackground()
        .task {
            try? await viewModel.loadCurrentUser()
        }
    }
}
