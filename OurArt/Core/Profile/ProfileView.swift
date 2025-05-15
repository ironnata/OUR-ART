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
    
    let preferenceOptions: [String] = ["Artist"]
    
    @State private var nickname: String = ""
    @State private var showImagePicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var showInputAlert = false
    
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
                            // ** 나중에 써먹을 ** 프로필사진 불러오기
        //                    if let urlString = viewModel.user?.profileImagePathUrl, let url = URL(string: urlString) {
        //                        AsyncImage(url: url) { image in
        //                            image
        //                                .resizable()
        //                                .frame(width: 100, height: 100)
        //                                .clipShape(Circle())
        //                                .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
        //                        } placeholder: {
        //                            ProgressView()
        //                                .frame(width: 100, height: 100)
        //                        }
        //                    }
                            
                            // ** 나중에 써먹을 ** 프로필사진 삭제
        //                    if viewModel.user?.profileImagePath != nil {
        //                        Button("Delete Image") {
        //                            viewModel.deleteProfileImage()
        //                        }
        //                    }
                            
                            ZStack {
                                if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .modifier(ProfileImageModifer())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .modifier(ProfileImageModifer())
                                        .foregroundStyle(Color.secondAccent)
                                }
                                
                                Button {
                                    showImagePicker.toggle()
                                } label: {
                                    Text("EDIT")
                                }
                                .modifier(SmallButtonModifier())
                                .offset(y: 30)
                                .photosPicker(isPresented: $showImagePicker, selection: $selectedItem, matching: .images)
                                // 선택 즉시 변경한 이미지 표시
                                .onChange(of: selectedItem) { _, newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            selectedImageData = data
                                        }
                                    }
                                }
                            }
                            
                            // 닉네임 표시하는 방법! 가릿
                            // Text("\(user.nickname ?? "" )")
                            
                            TextField("Nickname...", text: $nickname)
                                .modifier(TextFieldModifier())
                                .padding(.top, 20)
                            
                            if user.isAnonymous == false {
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
                                            .font(.headline)
                                            .buttonStyle(.borderedProminent)
                                            .tint(preferenceIsSelected(text: string) ? .accentColor : .secondary)
                                            .foregroundStyle(preferenceIsSelected(text: string) ? Color.accentButtonText : Color.accentColor)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 10)
                        
                        // ContentView 로 이동
                        Button {
                            if nickname.isEmpty {
                                showInputAlert = true
                            } else {
                                viewModel.addNickname(text: nickname)
                                print("Nickname was added")
                            }
                        } label: {
                            NavigationLink {
                                ContentView(showSignInView: $showSignInView)
                                    .toolbar(.hidden)
                            } label: {
                                Text("Continue to explore".uppercased())
                            }
                            .modifier(CommonButtonModifier())
                        }
                        .alert(isPresented: $showInputAlert) {
                            Alert(title: Text("Please input your name."))
                        }
                        // 프로필 사진 파이어스토어에 저장
                        .onChange(of: selectedItem) { _, newItem in
                            if let newItem {
                                Task {
                                    try await viewModel.saveProfileImage(item: newItem)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 50)
                .task {
                    try? await viewModel.loadCurrentUser()
                }
            }
            .viewBackground()
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(true))
    }
}

