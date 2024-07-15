//
//  TextSearchView.swift
//  OurArt
//
//  Created by Jongmo You on 27.06.24.
//

import SwiftUI

struct TextSearchView: View {
    @StateObject private var viewModel = MapSearchViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search for a place...", text: $searchText, onEditingChanged: { isEditing in
                    if isEditing {
                        viewModel.search(query: searchText)
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                if !viewModel.searchResults.isEmpty {
                    List(viewModel.searchResults, id: \.self) { result in
                        VStack(alignment: .leading) {
                            Text(result.title)
                                .font(.headline)
                            Text(result.subtitle)
                                .font(.subheadline)
                        }
                        .onTapGesture {
                            // Handle tap gesture if needed
                        }
                    }
                } else {
                    Spacer()
                    Text("No results")
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            .navigationTitle("Map Search")
        }
    }
}


#Preview {
    TextSearchView()
}
