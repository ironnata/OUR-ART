//
//  MyExhibitionsView.swift
//  OurArt
//
//  Created by Jongmo You on 29.04.24.
//

import SwiftUI

struct MyExhibitionsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = MyExhibitionViewModel()
    
    @State var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.userMyExhibitions, id: \.id.self) { item in
                    ExhibitionCellViewBuilder(exhibitionId: item.exhibitionId, myExhibitionId: item.id)
//                        .contextMenu(menuItems: {
//                            Button("Add to Favorites") {
                                // Favorite func 만들어서 변경
                                // viewModel.addFavoriteExhitions
//                                print("Added to Favorites")
//                            }
//                        })
                }
                .sectionBackground()
                .redacted(reason: isLoading ? .placeholder : [])
                .onFirstAppear {
                    isLoading = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isLoading = false
                    }
                }
            }
            .toolbarBackground()
            .listStyle(.plain)
        }
        .viewBackground()
        .task {
            viewModel.addListenerForMyExhibitions()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("My Exhibitions")
                    .font(.objectivityTitle2)
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                }
            }
        }
    }
}

#Preview {
    MyExhibitionsView()
}
