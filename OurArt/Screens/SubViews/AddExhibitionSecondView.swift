//
//  AddExhibitionView.swift
//  OurArt
//
//  Created by Jongmo You on 22.11.23.
//

import SwiftUI
import PhotosUI

struct AddExhibitionSecondView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = ExhibitionViewModel()
    
    @Binding var showAddingView: Bool
    
    @Binding var title: String
    @Binding var currentId: String
    
    @State private var artist: String = ""
    @State private var description: String = ""
    
    @State private var showImagePicker = false
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    @State private var selectedFromDate: Date = Date()
    @State private var selectedToDate: Date = Date()
    
    @State private var address: String = ""
    
    @State private var selectedFromTime: Date = Date()
    @State private var selectedToTime: Date = Date()
    
    @State private var showDeleteAlert: Bool = false
    
    let closingDaysOptions = ["Mon", "Tue", "Wed", "Thur", "Fri", "Sat", "Sun"]
    @State private var selectedClosingDays: Set<String> = []
    
    private func selectedClosingDays(text: String) -> Bool {
        viewModel.exhibition?.closingDays?.contains(text) == true
    }
    
    
    // MARK: - BODY
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let exhibition = viewModel.exhibition {
                        Text("Exhibition ID: \(exhibition.id)") // TEST용
                        
                        Text("Title: \(exhibition.title ?? "")") // TEST용
                        
                        VStack(alignment: .leading) {
                            Text("Poster")
                            VStack {
                                if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .frame(width: 120, height: 150)
                                } else {
                                    Image(systemName: "questionmark.square.dashed")
                                        .resizable()
                                        .frame(width: 120, height: 150)
                                }
                                
                                Button {
                                    showImagePicker.toggle()
                                } label: {
                                    // if 추가해서 사진 선택 상태에선 Edit 레이블 표시
                                    Image(systemName: "plus.rectangle")
                                        .resizable()
                                        .frame(width: 30, height: 20)
                                }
                                .photosPicker(isPresented: $showImagePicker, selection: $selectedImage, matching: .images)
                                .offset(y: -5)
                                .onChange(of: selectedImage, perform: { newValue in
                                    if let newValue {
                                        viewModel.savePosterImage(item: newValue)
                                    }
                                    Task {
                                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                            selectedImageData = data
                                        }
                                    }
                                })
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        } // POSTER
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        VStack(alignment: .leading) {
                            Text("Artist")
                            TextField("Artist...", text: $artist)
                                .modifier(TextFieldModifier())
                        } // ARTIST
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            Text("Date")
                            HStack(alignment: .center) {
                                Spacer()
                                DatePicker("", selection: $selectedFromDate, displayedComponents: [.date])
                                Text("to")
                                DatePicker("", selection: $selectedToDate, in: selectedFromDate... , displayedComponents: [.date])
                                Spacer()
                            }
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        } // DATE
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            Text("Address")
                            TextField("Address...", text: $address)
                                .modifier(TextFieldModifier())
                        } // ADDRESS
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            Text("Opening Hours")
                            HStack(alignment: .center, spacing: 20) {
                                Spacer()
                                DatePicker("", selection: $selectedFromTime, displayedComponents: [.hourAndMinute])
                                Text("-")
                                DatePicker("", selection: $selectedToTime, in: selectedFromTime... , displayedComponents: [.hourAndMinute])
                                Spacer()
                            }
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        } // OPENING HOURS
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            Text("Closed on")
                            HStack {
                                ForEach(closingDaysOptions, id: \.self) { day in
                                    Button(day) {
                                        if selectedClosingDays(text: day) {
                                            viewModel.removeClosingDays(text: day)
                                        } else {
                                            viewModel.addClosingDays(text: day)
                                        }
                                    }
                                    .font(.objectivityCaption)
                                    .buttonStyle(.borderedProminent)
                                    .tint(selectedClosingDays(text: day) ? .accentColor : .secondary)
                                }
                            }
                        } // CLOSED ON
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            Text("Description")
                            TextField("Describe...", text: $description, axis: .vertical)
                                .modifier(TextFieldDescriptionModifier())
                                .lineLimit(3...7)
                        } // DESCRIPTION
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 30)
                        
                        Button("Done") {
                            
                            Task {
                                try? await viewModel.addArtist(text: artist)
                                try? await viewModel.addDate(dateFrom: selectedFromDate, dateTo: selectedToDate)
                                try? await viewModel.addAddress(text: address)
                                try? await viewModel.addOpeningHours(openingHoursFrom: selectedFromTime, openingHoursTo: selectedToTime)
                                try? await viewModel.addDescription(text: description)
                                
                                showAddingView = false
                            }
                        }
                        .modifier(CommonButtonModifier())
                    }
                }
                .ignoresSafeArea()
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .onTapGesture {
                                showDeleteAlert = true
                            }
                            .alert(isPresented: $showDeleteAlert) {
                                Alert(
                                    title: Text("The whole data you wrote is going to be deleted, is it okay?"),
                                    primaryButton: .default(Text("OK")) {
                                        Task {
                                            try? await viewModel.deleteExhibition()
                                            showAddingView = false
                                        }
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Image(systemName: "chevron.left")
                            .imageScale(.large)
                            .onTapGesture {
                                dismiss()
                            }
                    }
                }
                .onAppear {
                    UIDatePicker.appearance().minuteInterval = 5
                }
                .navigationTitle("New Exhibiton")
            }
            .task {
                try? await viewModel.loadCurrentExhibition(id: currentId)
            }
        }
    }
}

#Preview {
    AddExhibitionSecondView(showAddingView: .constant(false), title: .constant(""), currentId: .constant(""))
}
