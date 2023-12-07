//
//  AddExhibitionView.swift
//  OurArt
//
//  Created by Jongmo You on 22.11.23.
//

import SwiftUI
import PhotosUI

struct AddExhibitionView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = ExhibitionViewModel()
    
    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var description: String = ""
    
    @State private var showImagePicker = false
    @State private var selectedImage: PhotosPickerItem? = nil
    
    @State private var selectedFromDate: Date = Date()
    @State private var selectedToDate: Date = Date()
    
    @State private var address: String = ""
    
    @State private var selectedFromTime: Date = Date()
    @State private var selectedToTime: Date = Date()
    
    let closingDaysOptions = ["Mon", "Tue", "Wed", "Thur", "Fri", "Sat", "Sun"]
    @State private var selectedClosingDays: Set<String> = []
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Poster")
                    VStack {
                        // 여기 if 추가해서 평소에는 안 보이다가 사진 선택 시 작게 썸네일 표시
                        Image(systemName: "questionmark.square.dashed")
                            .resizable()
                            .frame(width: 120, height: 150)
                        
                        Button {
                            showImagePicker.toggle()
                        } label: {
                            Image(systemName: "plus.rectangle")
                                .resizable()
                                .frame(width: 30, height: 20)
                        }
                        .photosPicker(isPresented: $showImagePicker, selection: $selectedImage, matching: .images)
                        .offset(y: -5)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                } // POSTER
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading) {
                    Text("Title")
                    TextField("Title...", text: $title)
                        .modifier(TextFieldModifier())
                } // Title
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading) {
                    Text("Artist")
                    TextField("Artist...", text: $artist)
                        .modifier(TextFieldModifier())
                } // Artist
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
                } // Date
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading) {
                    Text("Address")
                    TextField("Address...", text: $address)
                        .modifier(TextFieldModifier())
                } // Address
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
                } // Opening Hours
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading) {
                    Text("Closed on")
                    HStack {
                        ForEach(closingDaysOptions, id: \.self) { day in
                            Button(day) {
                                if self.selectedClosingDays.contains(day) {
                                    self.selectedClosingDays.remove(day)
                                } else {
                                    self.selectedClosingDays.insert(day)
                                }
                            }
                            .font(.objectivityCaption)
                            .buttonStyle(.borderedProminent)
                            .tint(selectedClosingDays.contains(day) ? .accentColor : .secondary)
                        }
                    }
                } // Closed on
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading) {
                    Text("Description")
                    TextField("Describe...", text: $description, axis: .vertical)
                        .modifier(TextFieldDescriptionModifier())
                        .lineLimit(3...7)
                } // Description
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 30)
                
                Button("Done") {
                    // register
                    let newExhibition = Exhibition(
                        id: UUID().uuidString,
                        dateCreated: Date(),
                        title: title,
                        artist: artist,
                        description: description,
                        dateFrom: selectedFromDate,
                        dateTo: selectedToDate,
                        address: address,
                        openingTimeFrom: selectedFromTime,
                        openingTimeTo: selectedToTime,
                        closingDays: Array(selectedClosingDays),
                        thumbnail: nil, // 수정 요
                        images: nil // 수정 요
                    )
                    
                    Task {
                        do {
                            try await viewModel.createExhibition(exhibition: newExhibition)
                            dismiss()
                        } catch {
                            // Handle any errors that occur during the upload
                            print("Error uploading exhibition: \(error)")
                        }
                    }
                    
//                    dismiss()
                }
                .modifier(CommonButtonModifier())
            }
            .ignoresSafeArea()
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "xmark")
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
    }
}

#Preview {
    AddExhibitionView()
}
