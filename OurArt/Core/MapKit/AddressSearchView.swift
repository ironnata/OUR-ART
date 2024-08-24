//
//  SearchView.swift
//  OurArt
//
//  Created by Jongmo You on 27.07.24.
//

import SwiftUI

struct AddressSearchView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = AddressSearchViewModel()

    @Binding var selectedAddress: String
    @Binding var isPresented: Bool
    
    private func searchForSelectedResult(from result: LocalizedSearchResult) {
        viewModel.searchForSelectedResult(result: result) { selectedResult in
            if let selectedResult = selectedResult {
                self.selectedAddress = selectedResult.formattedAddress
            }
            self.isPresented = false
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // 키보드 닫기
        }
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                TextField("Search...", text: $viewModel.queryFragment)
                    .modifier(TextFieldModifier())
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                }
            }
            
            List(viewModel.searchResults) { result in
                VStack(alignment: .leading) {
                    Text(result.name)
                        .font(.headline)
                    Text(result.formattedAddress)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                .onTapGesture {
                    self.searchForSelectedResult(from: result)
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
