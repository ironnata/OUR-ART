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
    @StateObject private var adModel = InterstitialViewModel()
    
    @Binding var showAddingView: Bool
    
    @Binding var title: String
    @Binding var currentId: String
    @Binding var isUploaded: Bool
    
    @State private var artist: String = ""
    @State private var description: String = ""
    
    @State private var showImageEditView = false
    @State private var wasImageUpdated = false
    @State private var showUpdateMessage = false
    
    @State private var selectedFromDate: Date = Date()
    @State private var selectedToDate: Date = Date()
    
    @State private var showSearchView = false
    @State private var selectedAddress = ""
    @State private var selectedCity = "Unknown"
    
    @State private var selectedFromTime: Date = Date()
    @State private var selectedToTime: Date = Date()
    
    @State private var showDeleteAlert = false
    
    let closingDaysOptions = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    @State private var selectedClosingDays: Set<String> = []
    
    private func selectedClosingDays(text: String) -> Bool {
        viewModel.exhibition?.closingDays?.contains(text) == true
    }
    
    
    // MARK: - BODY
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        if let exhibition = viewModel.exhibition {
                            SectionCard(title: "Poster", icon: "photo.stack") {
                                VStack {
                                    if let urlString = exhibition.posterImagePathUrl, let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .modifier(MidPosterSizeModifier())
                                        } placeholder: {
                                            Image(systemName: "photo.stack")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(maxWidth: 120)
                                        }
                                    } else {
                                        Image(systemName: "photo.stack")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 120)
                                    }
                                    
                                    Button {
                                        withAnimation {
                                            showImageEditView.toggle()
                                        }
                                    } label: {
                                        if exhibition.posterImagePathUrl != nil {
                                            Text("EDIT")
                                        } else {
                                            Text("+")
                                                .padding(.horizontal, 10)
                                        }
                                    }
                                    .modifier(SmallButtonModifier())
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
                                                    try? await viewModel.loadCurrentExhibition(id: currentId)
                                                }
                                            }
                                        }
                                    }) {
                                        let detents: Set<PresentationDetent> = (exhibition.posterImagePathUrl == nil) ? [.height(150)] : [.height(200)]
                                        
                                        ExhibitionImageEditView(showImageEditview: $showImageEditView, wasImageUpdated: $wasImageUpdated, exhibitionId: currentId)
                                            .presentationDragIndicator(.visible)
                                            .presentationDetents(detents)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            } // POSTER
                            
                            SectionCard(title: "Artist", icon: "person") {
                                TextField("Artist", text: $artist)
                                    .modifier(TextFieldModifier())
                                    .showClearButton($artist)
                            } // ARTIST
                            
                            SectionCard(title: "Date", icon: "calendar") {
                                HStack(alignment: .center) {
                                    Spacer()
                                    DatePicker("", selection: $selectedFromDate, displayedComponents: .date)
                                    Text("to")
                                    DatePicker("", selection: $selectedToDate, in: selectedFromDate... ,displayedComponents: .date)
                                    Spacer()
                                }
                                .datePickerStyle(.compact)
                                .labelsHidden()
                            } // DATE
                            
                            SectionCard(title: "Opening Hours", icon: "clock") {
                                HStack(alignment: .center, spacing: 20) {
                                    Spacer()
                                    DatePicker("", selection: $selectedFromTime, displayedComponents: .hourAndMinute)
                                    Text("-")
                                    DatePicker("", selection: $selectedToTime, in: selectedFromTime... , displayedComponents: .hourAndMinute)
                                    Spacer()
                                }
                                .datePickerStyle(.compact)
                                .labelsHidden()
                            } // OPENING HOURS
                            
                            SectionCard(title: "Closed on", icon: "xmark.circle") {
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
                            
                            SectionCard(title: "Address", icon: "location") {
                                TextField("Search location", text: $selectedAddress)
                                    .modifier(TextFieldModifier())
                                    .disabled(true)
                                    .onTapGesture {
                                        showSearchView = true
                                    }
                                    .showClearButton($selectedAddress)
                            } // ADDRESS
                            .sheet(isPresented: $showSearchView) {
                                AddressSearchView(selectedAddress: $selectedAddress, selectedCity: $selectedCity, isPresented: $showSearchView)
                                    .presentationDetents([.large])
                                    .interactiveDismissDisabled(true)
                            }
                            
                            SectionCard(title: "Description", icon: "text.justify.leading") {
                                TextField("Description", text: $description, axis: .vertical)
                                    .modifier(TextFieldDescriptionModifier())
                                    .lineSpacing(10)
                                    .lineLimit(5...15)
                            } // DESCRIPTION
                            .padding(.bottom, 30)
                            
                            Text("Tap DONE - watch an ad, then your dot's out there")
                                .font(.objectivityFootnote)
                                .foregroundStyle(.secondAccent)
                            
                            Button("Done") {
                                
                                Task {
                                    
                                    await adModel.presentAndWait()
                                    
                                    if artist.isEmpty {
                                        try? await viewModel.addArtist(text: "Unknown")
                                    } else {
                                        try? await viewModel.addArtist(text: artist)
                                    }
                                    try? await viewModel.updateUploadStatus(text: "completed")
                                    try? await viewModel.addDate(dateFrom: selectedFromDate, dateTo: selectedToDate)
                                    try? await viewModel.addOpeningHours(openingHoursFrom: selectedFromTime, openingHoursTo: selectedToTime)
                                    if selectedAddress.isEmpty {
                                        try? await viewModel.addAddress(text: "Not provided")
                                    } else {
                                        try? await viewModel.addAddress(text: selectedAddress)
                                    }
                                    try? await viewModel.addCity(text: selectedCity)
                                    try? await viewModel.addDescription(text: description)
                                    
                                    viewModel.addUserMyExhibition(exhibitionId: exhibition.id)
                                    
                                    isUploaded = true
                                    showAddingView = false
                                    
                                }
                            }
                            .modifier(CommonButtonModifier())
                            .navigationTitle(title)
                            .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                    .ignoresSafeArea()
                    .padding()
                    .toolbar {
                        CompatibleToolbarItem(placement: .topBarTrailing) {
                            Image(systemName: "xmark")
                                .imageScale(.large)
                                .onTapGesture {
                                    showDeleteAlert = true
                                    Task {
                                        // 사진 업로드된 경우, path 받아오기 위한 현재 전시 재호출
                                        try await viewModel.loadCurrentExhibition(id: currentId)
                                    }
                                }
                                .alert(isPresented: $showDeleteAlert) {
                                    Alert(
                                        title: Text("Your dot's still in progress. Leave without saving?"),
                                        primaryButton: .default(Text("OK")) {
                                            Task {
                                                try? await viewModel.deleteAllPosterImages()
                                                try? await viewModel.deleteExhibition()
                                                showAddingView = false
                                            }
                                        },
                                        secondaryButton: .cancel()
                                    )
                                }
                        }
                        
                        CompatibleToolbarItem(placement: .topBarLeading) {
                            Button {
                                Task {
                                    try? await viewModel.deleteAllPosterImages()
                                    try? await viewModel.deleteExhibition()
                                    dismiss()
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .imageScale(.large)
                            }
                        }
                    }
                    .onAppear {
                        UIDatePicker.appearance().minuteInterval = 5
                    }
                    .toolbarBackground()
                }
                .scrollDismissesKeyboard(.immediately)
                .keyboardAware(minDistance: 32)
                .task {
                    try? await viewModel.loadCurrentExhibition(id: currentId)
                }
            }
            .viewBackground()
        }
    }
}

#Preview {
    AddExhibitionSecondView(showAddingView: .constant(false), title: .constant(""), currentId: .constant(""), isUploaded: .constant(false))
}
