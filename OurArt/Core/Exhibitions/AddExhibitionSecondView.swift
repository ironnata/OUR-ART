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
    
    @State private var showImageEditView = false
    @State private var wasImageUpdated = false
    @State private var showUpdateMessage = false
    
    @State private var selectedFromDate: Date = Date()
    @State private var selectedToDate: Date = Date()
    
    @State private var showSearchView = false
    @State private var selectedAddress = ""
    @State private var selectedCity = ""
    
    @State private var selectedFromTime: Date = Date()
    @State private var selectedToTime: Date = Date()
    
    @State private var showDeleteAlert = false
    
    let closingDaysOptions = ["Mon", "Tue", "Wed", "Thur", "Fri", "Sat", "Sun"]
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
//                            Text("Exhibition ID: \(exhibition.id)") // TEST용
//                            
//                            Text("Title: \(exhibition.title ?? "")") // TEST용
                            
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
                                        // if 추가해서 사진 선택 상태에선 Edit 레이블 표시
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
                                        ExhibitionImageEditView(showImageEditview: $showImageEditView, wasImageUpdated: $wasImageUpdated, exhibitionId: currentId)
                                            .presentationDetents([.height(200)])
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            } // POSTER
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            
                            VStack(alignment: .leading) {
                                Text("Artist")
                                TextField("Artist...", text: $artist)
                                    .modifier(TextFieldModifier())
                                    .showClearButton($artist)
                            } // ARTIST
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading) {
                                Text("Date")
                                HStack(alignment: .center) {
//                                    Spacer()
                                    Text("From")
                                    DatePicker("", selection: $selectedFromDate, displayedComponents: .date)
                                    Text("to")
                                    DatePicker("", selection: $selectedToDate, in: selectedFromDate... ,displayedComponents: .date)
//                                    Spacer()
                                }
                                .datePickerStyle(.compact)
                                .labelsHidden()
                            } // DATE
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading) {
                                Text("Address")
                                
                                TextField("Search for places...", text: $selectedAddress)
                                    .modifier(TextFieldModifier())
                                    .disabled(true)
                                    .onTapGesture {
                                        showSearchView = true
                                    }
                                    .showClearButton($selectedAddress)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 500, alignment: .leading)
                            .sheet(isPresented: $showSearchView) {
                                AddressSearchView(selectedAddress: $selectedAddress, selectedCity: $selectedCity, isPresented: $showSearchView)
                                    .presentationDetents([.large])
                                    .interactiveDismissDisabled(true)
                            } // ADDRESS
                            
                            VStack(alignment: .leading) {
                                Text("Opening Hours")
                                HStack(alignment: .center, spacing: 20) {
//                                    Spacer()
                                    DatePicker("", selection: $selectedFromTime, displayedComponents: .hourAndMinute)
                                    Text("-")
                                    DatePicker("", selection: $selectedToTime, in: selectedFromTime... , displayedComponents: .hourAndMinute)
//                                    Spacer()
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
                                TextField("Describe...", text: $description, axis: .vertical)
                                    .modifier(TextFieldDescriptionModifier())
                                    .lineLimit(3...10)
                                    .lineSpacing(10)
                            } // DESCRIPTION
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 30)
                            
                            Button("Done") {
                                
                                Task {
                                    try? await viewModel.addArtist(text: artist)
                                    try? await viewModel.addDate(dateFrom: selectedFromDate, dateTo: selectedToDate)
                                    try? await viewModel.addAddress(text: selectedAddress)
                                    try? await viewModel.addCity(text: selectedCity)
                                    try? await viewModel.addOpeningHours(openingHoursFrom: selectedFromTime, openingHoursTo: selectedToTime)
                                    try? await viewModel.addDescription(text: description)
                                    
                                    viewModel.addUserMyExhibition(exhibitionId: exhibition.id)
                                    
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
                                    Task {
                                        // 사진 업로드된 경우, path 받아오기 위한 현재 전시 재호출
                                        try await viewModel.loadCurrentExhibition(id: currentId)
                                    }
                                }
                                .alert(isPresented: $showDeleteAlert) {
                                    Alert(
                                        title: Text("Not saved yet. Leave anyway?"),
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
                        
                        ToolbarItem(placement: .principal) {
                            Text("New Exhibition")
                                .font(.objectivityBody)
                        }
                        ToolbarItem(placement: .topBarLeading) {
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
    AddExhibitionSecondView(showAddingView: .constant(false), title: .constant(""), currentId: .constant(""))
}
