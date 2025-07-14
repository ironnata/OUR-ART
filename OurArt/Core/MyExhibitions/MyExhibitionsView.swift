//
//  MyExhibitionsView.swift
//  OurArt
//
//  Created by Jongmo You on 29.04.24.
//

import SwiftUI

struct MyExhibitionsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var myExhibitionVM = MyExhibitionViewModel()
    @StateObject private var exhibitionVM = ExhibitionViewModel()
    
    @State var isLoading: Bool = false
    @State private var isRefreshing = false
    @State private var refreshCount = 0
    
    private func refreshData() async {
        isRefreshing = true
        
        try? await Task.sleep(for: .seconds(0.8))
        
        // exhibitionVM의 리스너 재설정
        exhibitionVM.removeListenerForAllExhibitions()
        myExhibitionVM.removeListenerForMyExhibitions()
        
        exhibitionVM.addListenerForAllExhibitions()
        myExhibitionVM.addListenerForMyExhibitions()
        
        refreshCount += 1
        isRefreshing = false
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(myExhibitionVM.userMyExhibitions, id: \.id.self) { item in
                    ExhibitionCellViewBuilder(exhibitionId: item.exhibitionId, myExhibitionId: item.id)
                        .environmentObject(exhibitionVM)
//                        .contextMenu(menuItems: {
//                            Button("Add to Favorites") {
                                // Favorite func 만들어서 변경
                                // viewModel.addFavoriteExhitions
//                                print("Added to Favorites")
//                            }
//                        })
                }
                .id("exhibitions-\(refreshCount)")
                .sectionBackground()
                .redacted(reason: isLoading ? .placeholder : [])
                .onFirstAppear {
                    isLoading = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isLoading = false
                    }
                }
            }
            .refreshable {
                await refreshData()
                print("\(refreshCount) refreshed")
            }
            .toolbarBackground()
            .listStyle(.plain)
        }
        .viewBackground()
        .onAppear {
            myExhibitionVM.addListenerForMyExhibitions()
            exhibitionVM.addListenerForAllExhibitions()
        }
        .onDisappear {
            myExhibitionVM.removeListenerForMyExhibitions()
            exhibitionVM.removeListenerForAllExhibitions()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("My Exhibitions")
                    .font(.objectivityTitle2)
            }
            
            ToolbarBackButton()
        }
    }
}

#Preview {
    MyExhibitionsView()
}
