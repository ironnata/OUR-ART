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
    @State private var description: String = ""
    
    @State private var selectedFromDate: Date = Date()
    @State private var selectedToDate: Date = Date()
    
    @State private var address: String = ""
    
    @State private var selectedFromTime: Date = Date()
    @State private var selectedToTime: Date = Date()
    
    let closingDaysOptions = ["Mon", "Tue", "Wed", "Thur", "Fri", "Sat", "Sun"]
    
    private func closingDayIsSelected(text: String) -> Bool {
        return viewModel.exhibitions.contains { exhibition in
            exhibition.closingDays?.contains(text) == true
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Title")
                    TextField("Title...", text: $title)
                        .modifier(TextFieldModifier())
                } // Title
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
                                if closingDayIsSelected(text: day) {
                                    // ProfileView 109번째 줄
                                } else {
                                    // ProfileView 111번째 줄
                                }
                            }
                            .font(.objectivityCaption)
                            .buttonStyle(.borderedProminent)
                            .tint(closingDayIsSelected(text: day) ? .accentColor : .secondary)
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
                    
                    dismiss()
                }
                .modifier(CommonButtonModifier())
            }
            .padding()
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
