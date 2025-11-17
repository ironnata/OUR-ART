//
//  ProfileImageEditView.swift
//  OurArt
//
//  Created by Jongmo You on 12.08.24.
//

import SwiftUI
import PhotosUI

struct ProfileImageEditView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = ProfileViewModel()
    
    @Binding var showImageEditview: Bool
    @Binding var wasImageUpdated: Bool
    @Binding var showSignInView: Bool
    
    @State private var showImagePicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading ,spacing: 30) {
                if let user = viewModel.user {
                    HStack(alignment: .center) {
                        ZStack {
                            if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .clipShape(Circle())
                            } else if let urlString = user.profileImagePathUrl, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .frame(width: 45, height: 45)
                                        .clipShape(Circle())
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 45, height: 45)
                                        .clipShape(Circle())
                                        .foregroundStyle(Color.secondAccent)
                                }
                                .id(urlString)
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .clipShape(Circle())
                                    .foregroundStyle(Color.secondAccent)
                            }
                        }
                        
                        Spacer()
                        
                        Text("Edit Profile Image")
                        
                        Spacer()
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                        }
                    }
                    
                    Divider()
                        .padding(.top, -10)
                    
                    VStack {
                        Button {
                            showImagePicker.toggle()
                        } label: {
                            HStack(alignment: .center, spacing: 20) {
                                Image(systemName: "photo")
                                Text("Select Profile Image")
                            }
                        }
                        .padding(.bottom, 30)
                        
                        if user.profileImagePathUrl != nil {
                            Button(role: .destructive) {
                                showDeleteAlert = true
                            } label: {
                                HStack(alignment: .center, spacing: 20) {
                                    Image(systemName: "trash")
                                    Text("Delete Profile Image")
                                }
                            }
                            .confirmationDialog("", isPresented: $showDeleteAlert, titleVisibility: .hidden) {
                                Button("Delete", role: .destructive) {
                                    //                                    viewModel.deleteProfileImage() // 단일 이미지 삭제
                                    viewModel.deleteAllProfileImages()
                                    wasImageUpdated = true
                                    dismiss()
                                }
                            }
                        }
                    }
                    .padding(.top, -20)
                    .sectionBackground()
                    .photosPicker(isPresented: $showImagePicker, selection: $selectedItem, matching: .images)
                    // 선택 즉시 변경한 이미지 표시
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            viewModel.deleteAllProfileImages()
                            
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                            
                            if let newItem {
                                try await viewModel.saveProfileImage(item: newItem)
                                wasImageUpdated = true
                                dismiss()
                            }
                        }
                    }
                }
            }
            .padding(.top, 0)
        }
        .frame(maxHeight: 300)
        .padding()
        .viewBackground()
        .task {
            try? await viewModel.loadCurrentUser()
        }
    }
}

#Preview {
    ProfileImageEditView(showImageEditview: .constant(false), wasImageUpdated: .constant(false), showSignInView: .constant(false))
}
