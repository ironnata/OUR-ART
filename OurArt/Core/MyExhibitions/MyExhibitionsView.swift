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
    
    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.userMyExhibitions, id: \.id.self) { item in
                    ExhibitionCellViewBuilder(exhibitionId: item.exhibitionId, myExhibitionId: item.id)
                        .contextMenu(menuItems: {
                            Button("Remove from Favorites") {
                                // Favorite func 만들어서 변경
                                viewModel.deleteMyExhibitions(myExhibitionId: item.id)
                            }
                        })
                }
                .sectionBackground()
                .listRowSeparator(.hidden)
            }
            .toolbarBackground()
            .listStyle(.plain)
        }
        .viewBackground()
        .onFirstAppear {
            viewModel.addListenerForMyExhibitions()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("My Exhibitions")
                    .font(.objectivityTitle2)
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .onTapGesture {
                        dismiss()
                    }
            }
        }
    }
}

#Preview {
    MyExhibitionsView()
}
