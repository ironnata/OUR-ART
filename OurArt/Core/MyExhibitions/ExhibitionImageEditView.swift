//
//  ExhibitionImageEditView.swift
//  OurArt
//
//  Created by Jongmo You on 21.08.24.
//

import SwiftUI
import PhotosUI

struct ExhibitionImageEditView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = ExhibitionViewModel()
    
    @Binding var showImageEditview: Bool
    @Binding var wasImageUpdated: Bool
    var exhibitionId: String
    
    @State private var showImagePicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading ,spacing: 30) {
                if let exhibition = viewModel.exhibition {
                    HStack(alignment: .center) {
                        ZStack {
                            if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .modifier(SmallPosterSizeModifier())
                            } else if let urlString = exhibition.posterImagePathUrl, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .modifier(SmallPosterSizeModifier())
                                } placeholder: {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 45)
                                }
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 45)
                            }
                        }
                        
                        Spacer()
                        
                        Text("Edit Poster Image")
                        
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
                                Text("Select Poster Image")
                            }
                        }
                        .padding(.bottom, 30)
                        
                        if exhibition.posterImagePathUrl != nil {
                            Button(role: .destructive) {
                                showDeleteAlert = true
                            } label: {
                                HStack(alignment: .center, spacing: 20) {
                                    Image(systemName: "trash")
                                    Text("Delete Poster Image")
                                }
                            }
                            .confirmationDialog("", isPresented: $showDeleteAlert, titleVisibility: .hidden) {
                                Button("Delete", role: .destructive) {
                                    //                                    viewModel.deleteProfileImage() // 단일 이미지 삭제
                                    Task {
                                        try await viewModel.deleteAllPosterImages()
                                        wasImageUpdated = true
                                        dismiss()
                                    }
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
                            try await viewModel.deleteAllPosterImages()
                            
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                            
                            if let newItem {
                                viewModel.savePosterImage(item: newItem)
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
            try? await viewModel.loadCurrentExhibition(id: exhibitionId)
        }
    }
}

#Preview {
    ExhibitionImageEditView(showImageEditview: .constant(false), wasImageUpdated: .constant(false), exhibitionId: "1")
}
