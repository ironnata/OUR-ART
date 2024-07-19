//
//  AddressSearchView.swift
//  OurArt
//
//  Created by Jongmo You on 15.07.24.
//

import SwiftUI

struct AddressSearchView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var selectedAddress: String
    @Binding var isPresented: Bool

    @StateObject private var placesManager = GooglePlacesManager()
    @State private var query = ""
    
    private func addressWithoutCountry(from address: String) -> String {
        let components = address.split(separator: ",")
        guard components.count > 1 else {
            return address
        }
        return components.dropLast().joined(separator: ", ")
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 10) {
                TextField("Search for places...", text: $query)
                    .modifier(TextFieldModifier())
                    .onChange(of: query) { _, newQuery in
                        self.placesManager.updateQuery(newQuery)
                    }
                    .showClearButton($query)
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                }
            }
            
            List {
                ForEach(placesManager.searchResults, id: \.self) { place in
                    VStack(alignment: .leading) {
                        Text(place.name ?? "")
                            .font(.headline)
                        Text(place.formattedAddress ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    .onTapGesture {
                        self.selectedAddress = addressWithoutCountry(from: place.formattedAddress ?? place.name ?? "")
                        self.query = ""
                        self.isPresented = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // 키보드 닫기
                    }
                }                    
                .sectionBackground()
            }
            .listStyle(.plain)
        }
        .padding()
        .viewBackground()
    }
}

#Preview {
    AddressSearchView(selectedAddress: .constant(""), isPresented: .constant(false))
}
