//
//  ProfileView.swift
//  OurArt
//
//  Created by Jongmo You on 19.10.23.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    let preferenceOptions: [String] = ["Aritst", "Audience"]
    
    @State private var nickname: String = ""
    @State private var showImagePicker = false
    @State private var photoItem: PhotosPickerItem?
    @State private var imageData: Data? = nil
    @State private var showInputAlert = false
    
    private func preferenceIsSelected(text: String) -> Bool {
        viewModel.user?.preferences?.contains(text) == true
    }
    
    
    // MARK: - BODY
    
    var body: some View {
        VStack {
            if let user = viewModel.user {
                
                Spacer()
                
                VStack(spacing: 10) {
                    ZStack {
                        // ** 나중에 써먹을 ** 프로필사진 불러오기 기능
                        //                        if let imageData, let image = UIImage(data: imageData) {
                        //                            Image(uiImage: image)
                        //                                .resizable()
                        //                                .frame(width: 100, height: 100)
                        //                                .clipShape(Circle())
                        //                                .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                        
                        if let image = viewModel.profileImage {
                            image
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(Color.accentColor)
                        }
                        
                        Button {
                            showImagePicker.toggle()
                        } label: {
                            Text("EDIT")
                        }
                        .modifier(SmallButtonModifier())
                        .offset(y: 30)
                        .photosPicker(isPresented: $showImagePicker, selection: $viewModel.selectedImage)
                        // 프로필 사진 파이어스토어에 저장
                        .onChange(of: viewModel.selectedImage, perform: { newValue in
                            if let newValue {
                                viewModel.saveProfileImage(item: newValue)
                            }
                        })
                    }
                    
                    // 닉네임 표시하는 방법! 가릿
                    // Text("\(user.nickname ?? "" )")
                    
                    TextField("Nickname...", text: $nickname)
                        .modifier(TextFieldModifier())
                        .padding(.top, 20)
                    
                    VStack {
                        Text("Choose who you are: \((user.preferences ?? []).joined(separator: " and "))")
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
                                .font(.headline)
                                .buttonStyle(.borderedProminent)
                                .tint(preferenceIsSelected(text: string) ? .accentColor : .secondary)
                            }
                        }
                    }
                }
                
                Divider()
                    .padding(.vertical, 10)
                
                Button {
                    if nickname.isEmpty {
                        showInputAlert = true
                    } else {
                        viewModel.addNickname(text: nickname)
                        // ContentView 로 이동 추가
                    }
                    
                } label: {
                    Text("Create the profile".uppercased())
                }
                .modifier(CommonButtonModifier())
                .alert(isPresented: $showInputAlert) {
                    Alert (title: Text("Please input your name."))
                }
                
            }
        }
        .overlay(alignment: .topTrailing) {
            NavigationLink {
                SettingsScreen(showSignInView: $showSignInView)
            } label: {
                Image(systemName: "gearshape.2")
            }
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 50)
        .task {
            try? await viewModel.loadCurrentUser()
            
            if let user = viewModel.user, let path = user.profileImagePath {
                let data = try? await StorageManager.shared.getData(userId: user.userId, path: path)
                self.imageData = data
            }
        }
    }
}

#Preview {
    NavigationStack {
        RootView()
    }
}
