//
//  ProfileEditView.swift
//  OurArt
//
//  Created by Jongmo You on 15.11.23.
//

import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    let preferenceOptions: [String] = ["Aritst", "Audience"]
    
    @State private var nickname: String = ""
    @State private var showImagePicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var url: URL? = nil
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
                            
                            ZStack {
                                if let urlString = user.profileImagePathUrl, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                                    } placeholder: {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .foregroundStyle(Color.accentColor)
                                    }
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
                                .onChange(of: selectedItem) { newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            selectedImageData = data
                                        }
                                    }
                                }
                            }
                            
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
                                        .font(.objectivityBody)
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
                                dismiss()
                            }
                            
                        } label: {
                            Text("Done".uppercased())
                        }
                        .modifier(CommonButtonModifier())
                        .alert(isPresented: $showInputAlert) {
                            Alert(title: Text("Please input your name."))
                        }
                        // 프로필 사진 파이어스토어에 저장
                        .onChange(of: selectedItem, perform: { newValue in
                            if let newValue {
                                viewModel.saveProfileImage(item: newValue)
                            }
                        })
                        
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 50)
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
