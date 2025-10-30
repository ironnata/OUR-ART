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
    
    @FocusState private var isFocused: Bool
    
    @Binding var showEditView: Bool
    var exhibitionId: String
    let placeholderImage = Image("Business and Finance _ businessman, confusion, uncertainty, questioning, perplexed")
    
    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var description: String = ""
    
    @State private var selectedAddress: String = ""
    @State private var selectedCity: String = ""
    @State private var showSearchView = false
    
    @State private var showImageEditView = false
    @State private var wasImageUpdated = false
    @State private var showUpdateMessage = false
    
    @State private var onlineLink = ""
    @State private var showOnlineLinkSection = false
    
    @State private var selectedFromDate: Date = Date()
    @State private var selectedToDate: Date = Date()
    
    @State private var selectedFromTime: Date = Date()
    @State private var selectedToTime: Date = Date()
    
    private var noSelectedTime: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    let closingDaysOptions = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    @State private var selectedClosingDays: Set<String> = []
    
    private func selectedClosingDays(text: String) -> Bool {
        viewModel.exhibition?.closingDays?.contains(text) == true
    }
    
    private func handleDoneButton() {
        let finalTitle = title.isEmpty ? (viewModel.exhibition?.title ?? "") : title
        let finalArtist = artist.isEmpty ? (viewModel.exhibition?.artist ?? "") : artist
        let finalDescription = description
        let finalAddress = selectedAddress.isEmpty ? (viewModel.exhibition?.address ?? "") : selectedAddress
        let finalCity = selectedCity.isEmpty ? (viewModel.exhibition?.city ?? "") : selectedCity
        let finalOnlineLink = onlineLink.isEmpty ? (viewModel.exhibition?.onlineLink ?? "") : onlineLink
        
        Task {
            try? await viewModel.addTitle(text: finalTitle)
            try? await viewModel.addArtist(text: finalArtist)
            try? await viewModel.addDate(dateFrom: selectedFromDate, dateTo: selectedToDate)
            try? await viewModel.addAddress(text: finalAddress)
            try? await viewModel.addCity(text: finalCity)
            try? await viewModel.addOpeningHours(openingHoursFrom: selectedFromTime, openingHoursTo: selectedToTime)
            try? await viewModel.addOnlineLink(text: finalOnlineLink)
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
                            SectionCard(title: "Poster", icon: "photo.stack") {
                                VStack {
                                    if let urlString = exhibition.posterImagePathUrl, let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .modifier(MidPosterSizeModifier())
                                        } placeholder: {
                                            placeholderImage
                                                .renderingMode(.template)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundStyle(Color.accent)
                                                .frame(maxWidth: 160)
                                        }
                                    } else {
                                        placeholderImage
                                            .renderingMode(.template)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundStyle(Color.accent)
                                            .frame(maxWidth: 160)
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
                                                    try? await viewModel.loadCurrentExhibition(id: exhibitionId)
                                                }
                                            }
                                        }
                                    }) {
                                        let detents: Set<PresentationDetent> = (exhibition.posterImagePathUrl == nil) ? [.height(150)] : [.height(200)]
                                        
                                        ExhibitionImageEditView(showImageEditview: $showImageEditView, wasImageUpdated: $wasImageUpdated, exhibitionId: exhibitionId)
                                            .presentationDragIndicator(.visible)
                                            .presentationDetents(detents)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            } // POSTER
                            
                            SectionCard(title: "Title", icon: "sparkles") {
                                TextField(exhibition.title ?? "title", text: $title)
                                    .modifier(TextFieldModifier())
                                    .showClearButton($title)
                            } // TITLE
                            
                            SectionCard(title: "Artist", icon: "person") {
                                TextField(exhibition.artist ?? "artist", text: $artist)
                                    .modifier(TextFieldModifier())
                                    .showClearButton($artist)
                            } // ARTIST
                            
                            SectionCard(title: "Date", icon: "calendar") {
                                HStack(alignment: .center) {
                                    Spacer()
                                    DatePicker("", selection: $selectedFromDate, displayedComponents: .date)
                                        .onAppear {
                                            self.selectedFromDate = exhibition.dateFrom ?? Date()
                                        }
                                    Text("to")
                                    DatePicker("", selection: $selectedToDate, in: selectedFromDate... , displayedComponents: .date)
                                        .onAppear {
                                            self.selectedToDate = exhibition.dateTo ?? Date()
                                        }
                                    Spacer()
                                }
                                .datePickerStyle(.compact)
                                .labelsHidden()
                            } // DATE
                            
                            SectionCard(title: "Opening Hours", icon: "clock") {
                                HStack(alignment: .center, spacing: 20) {
                                    Spacer()
                                    DatePicker("", selection: $selectedFromTime, displayedComponents: .hourAndMinute)
                                        .onAppear {
                                            self.selectedFromTime = exhibition.openingTimeFrom ?? Date()
                                        }
                                    Text("-")
                                    DatePicker("", selection: $selectedToTime, in: selectedFromTime... , displayedComponents: .hourAndMinute)
                                        .onAppear {
                                            self.selectedToTime = exhibition.openingTimeTo ?? Date()
                                        }
                                    Spacer()
                                }
                                .datePickerStyle(.compact)
                                .labelsHidden()
                            } button: {
                                Button {
                                    selectedFromTime = noSelectedTime
                                    selectedToTime = noSelectedTime
                                } label: {
                                    Text("No hours")
                                        .modifier(SmallButtonModifier())
                                }
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
                                TextField(exhibition.address ?? "Search location", text: $selectedAddress)
                                    .modifier(TextFieldModifier())
                                    .disabled(true)
                                    .onTapGesture {
                                        showSearchView = true
                                    }
                                    .showClearButton($selectedAddress)
                            } button: {
                                Button {
                                    selectedCity = "Online"
                                    selectedAddress = "Online"
                                    withAnimation(.smooth(duration: 0.7)) {
                                        showOnlineLinkSection = true
                                    }
                                } label: {
                                    Text("Online")
                                        .modifier(SmallButtonModifier())
                                }
                            } // ADDRESS
                            .sheet(isPresented: $showSearchView) {
                                AddressSearchView(selectedAddress: $selectedAddress, selectedCity: $selectedCity, isPresented: $showSearchView)
                                    .presentationDetents([.large])
                                    .interactiveDismissDisabled(true)
                            }
                            .onAppear {
                                if exhibition.address == "Online" {
                                    showOnlineLinkSection = true
                                }
                            }
                            .onChange(of: selectedAddress) { oldValue, newValue in
                                if selectedAddress != "Online" {
                                    showOnlineLinkSection = false
                                }
                            }
                            
                            if showOnlineLinkSection {
                                SectionCard(title: "Online Link", icon: "link") {
                                    TextField(exhibition.onlineLink ?? "online link", text: $onlineLink)
                                        .modifier(TextFieldDescriptionModifier())
                                        .keyboardType(.URL)
                                        .autocorrectionDisabled(true)
                                        .textInputAutocapitalization(.never)
                                        .focused($isFocused)
                                        .onChange(of: isFocused) { _, newValue in
                                            if newValue {
                                                // onlineLink가 비어있거나, 접두사로 시작하지 않을 경우에만 추가
                                                if onlineLink.isEmpty || !onlineLink.hasPrefix("https://") {
                                                    onlineLink = "https://" + onlineLink
                                                }
                                            }
                                        }
                                        .showClearButton($onlineLink)
                                }
                            }
                            
                            SectionCard(title: "Description", icon: "text.justify.leading") {
                                TextField("description", text: $description, axis: .vertical)
                                    .modifier(TextFieldDescriptionModifier())
                                    .lineSpacing(10)
                                    .lineLimit(5...15)
                                    .onAppear {
                                        self.description = exhibition.description ?? ""
                                    }
                            } // DESCRIPTION
                            .padding(.bottom, 30)
                            
                            Button("Done") {
                                handleDoneButton()
                            }
                            .modifier(CommonButtonModifier())
                            .toolbar {
                                ToolbarBackButton()
                                
                                CompatibleToolbarItem(placement: .title) {
                                    Text(exhibition.title ?? "")
                                        .font(.objectivityTitle3)
                                        .frame(maxWidth: 200)
                                }
                                
                            }
                        }
                    }
                    .ignoresSafeArea()
                    .padding()
                    .onAppear {
                        UIDatePicker.appearance().minuteInterval = 5
                    }
                }
                .scrollDismissesKeyboard(.immediately)
                .keyboardAware(minDistance: 32)
                .toolbarBackground()
                .task {
                    try? await viewModel.loadCurrentExhibition(id: exhibitionId)
                }
                
                if showUpdateMessage {
                    VStack {
                        BannerMessage(text: "Poster image has successfully updated!")
                        Spacer()
                    }
                    .padding(.top, 100)
                }
            }
            .viewBackground()
        }
    }
}


#Preview {
    EditMyExhibitionView(showEditView: .constant(false), exhibitionId: "")
}
