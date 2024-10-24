//
//  EditMyExhibitionView.swift
//  OurArt
//
//  Created by Jongmo You on 14.05.24.
//

import SwiftUI
import PhotosUI

struct EditMyExhibitionView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = ExhibitionViewModel()
    
    @Binding var showEditView: Bool
    var exhibitionId: String
    
    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var description: String = ""
    
    @State private var selectedAddress: String = ""
    @State private var selectedCity: String = ""
    @State private var showSearchView = false
    
    @State private var showImageEditView = false
    
    @State private var selectedFromDate: Date = Date()
    @State private var selectedToDate: Date = Date()
    @State private var selectedFromTime: Date = Date()
    @State private var selectedToTime: Date = Date()
    
    let closingDaysOptions = ["Mon", "Tue", "Wed", "Thur", "Fri", "Sat", "Sun"]
    @State private var selectedClosingDays: Set<String> = []
    
    private func selectedClosingDays(text: String) -> Bool {
        viewModel.exhibition?.closingDays?.contains(text) == true
    }
    
    private func handleDoneButton() {
        let finalTitle = title.isEmpty ? (viewModel.exhibition?.title ?? "") : title
        let finalArtist = artist.isEmpty ? (viewModel.exhibition?.artist ?? "") : artist
        let finalDescription = description.isEmpty ? (viewModel.exhibition?.description ?? "") : description
        let finalAddress = selectedAddress.isEmpty ? (viewModel.exhibition?.address ?? "") : selectedAddress
        let finalCity = selectedCity.isEmpty ? (viewModel.exhibition?.city ?? "") : selectedCity
        
        Task {
            try? await viewModel.addTitle(text: finalTitle)
            try? await viewModel.addArtist(text: finalArtist)
            try? await viewModel.addDate(dateFrom: selectedFromDate, dateTo: selectedToDate)
            try? await viewModel.addAddress(text: finalAddress)
            try? await viewModel.addCity(text: finalCity)
            try? await viewModel.addOpeningHours(openingHoursFrom: selectedFromTime, openingHoursTo: selectedToTime)
            try? await viewModel.addDescription(text: finalDescription)
            
            showEditView = false
        }
    }
    
    
    // MARK: - BODY
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        if let exhibition = viewModel.exhibition {
                            VStack(alignment: .leading) {
                                Text("Poster")
                                VStack {
                                    if let urlString = exhibition.posterImagePathUrl, let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .modifier(MidPosterSizeModifier())
                                        } placeholder: {
                                            Image(systemName: "photo.on.rectangle.angled")
                                                .resizable()
                                                .frame(width: 150, height: 120)
                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                        }
                                    } else {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .resizable()
                                            .frame(width: 150, height: 120)
                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                    }
                                    
                                    
                                    Button {
                                        withAnimation {
                                            showImageEditView.toggle()
                                        }
                                    } label: {
                                        Text("EDIT")
                                    }
                                    .modifier(SmallButtonModifier())
                                    .sheet(isPresented: $showImageEditView, onDismiss: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            Task {
                                                try? await viewModel.loadCurrentExhibition(id: exhibitionId)
                                            }
                                        }
                                    }) {
                                        ExhibitionImageEditView(showImageEditview: $showImageEditView, exhibitionId: exhibitionId)
                                            .presentationDetents([.height(200)])
                                    }
//                                    .onChange(of: selectedImage) { _, newValue in
//                                        Task {
//                                            //                                                try await viewModel.deleteExistedPosterImage()
//                                            
//                                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
//                                                selectedImageData = data
//                                            }
//                                        }
//                                        
//                                        if let newValue {
//                                            viewModel.savePosterImage(item: newValue)
//                                        }
//                                    }
                                    
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            } // POSTER
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading) {
                                Text("Title")
                                TextField(exhibition.title ?? "Title...", text: $title)
                                    .modifier(TextFieldModifier())
                                    .showClearButton($title)
                            } // TITLE
                            
                            VStack(alignment: .leading) {
                                Text("Artist")
                                TextField(exhibition.artist ?? "Artist...", text: $artist)
                                    .modifier(TextFieldModifier())
                                    .showClearButton($artist)
                            } // ARTIST
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading) {
                                Text("Date")
                                HStack(alignment: .center) {
                                    DatePicker("", selection: $selectedFromDate, displayedComponents: .date)
                                        .onAppear {
                                            self.selectedFromDate = exhibition.dateFrom ?? Date()
                                        }
                                    Text("to")
                                    DatePicker("", selection: $selectedToDate, in: selectedFromDate... , displayedComponents: .date)
                                        .onAppear {
                                            self.selectedToDate = exhibition.dateTo ?? Date()
                                        }
                                }
                                .datePickerStyle(.compact)
                                .labelsHidden()
                            } // DATE
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading) {
                                Text("Address")
                                TextField(exhibition.address ?? "Search for places...", text: $selectedAddress)
                                    .modifier(TextFieldModifier())
                                    .disabled(true)
                                    .onTapGesture {
                                        showSearchView = true
                                    }
                                    .showClearButton($selectedAddress)
                            } // ADDRESS
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .sheet(isPresented: $showSearchView) {
                                AddressSearchView(selectedAddress: $selectedAddress, selectedCity: $selectedCity, isPresented: $showSearchView)
                                    .presentationDetents([.large])
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Opening Hours")
                                HStack(alignment: .center, spacing: 20) {
                                    DatePicker("", selection: $selectedFromTime, displayedComponents: .hourAndMinute)
                                        .onAppear {
                                            self.selectedFromTime = exhibition.openingTimeFrom ?? Date()
                                        }
                                    Text("-")
                                    DatePicker("", selection: $selectedToTime, in: selectedFromTime... , displayedComponents: .hourAndMinute)
                                        .onAppear {
                                            self.selectedToTime = exhibition.openingTimeTo ?? Date()
                                        }
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
                                        .foregroundStyle(Color.accentButtonText)
                                        .tint(selectedClosingDays(text: day) ? .accentColor : .secondary)
                                    }
                                }
                            } // CLOSED ON
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading) {
                                Text("Description")
                                TextField(exhibition.description ?? "Describe...", text: $description, axis: .vertical)
                                    .modifier(TextFieldDescriptionModifier())
                                    .lineLimit(3...7)
                                    .lineSpacing(10)
                            } // DESCRIPTION
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 30)
                            
                            Button("Done") {
                                handleDoneButton()
                            }
                            .modifier(CommonButtonModifier())
                            .navigationTitle(exhibition.title ?? "")
                            .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                    .ignoresSafeArea()
                    .padding()
                    .toolbar {
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
                }
                .toolbarBackground()
                .task {
                    try? await viewModel.loadCurrentExhibition(id: exhibitionId)
                }
            }
            .viewBackground()
        }
    }
}


#Preview {
    EditMyExhibitionView(showEditView: .constant(false), exhibitionId: "")
}
