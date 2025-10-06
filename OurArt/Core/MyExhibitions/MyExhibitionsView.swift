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
                
//                ForEach(myExhibitionVM.userMyExhibitions, id: \.id.self) { item in
//                    ExhibitionCellViewBuilder(exhibitionId: item.exhibitionId, myExhibitionId: item.id)
//                        .environmentObject(exhibitionVM)
////                        .contextMenu(menuItems: {
////                            Button("Add to Favorites") {
//                                // Favorite func 만들어서 변경
//                                // viewModel.addFavoriteExhitions
////                                print("Added to Favorites")
////                            }
////                        })
//                }
                Section {
                    ForEach(myExhibitionVM.myOngoingOrUpcoming) { exhibition in
                        ExhibitionCellViewBuilder(exhibitionId: exhibition.id, myExhibitionId: myExhibitionVM.userMyExhibitions.first(where: { $0.exhibitionId == exhibition.id })?.id)
                            .environmentObject(exhibitionVM)
                    }
                } header: {
                    if myExhibitionVM.myOngoingOrUpcoming.isEmpty {
                        EmptyView()
                    } else {
                        Text("Ongoing / Upcoming")
                            .sectionHeaderBackground()
                    }
                }
                .sectionBackground()
                
                Section {
                    ForEach(myExhibitionVM.myPast) { exhibition in
                        ExhibitionCellViewBuilder(exhibitionId: exhibition.id, myExhibitionId: myExhibitionVM.userMyExhibitions.first(where: { $0.exhibitionId == exhibition.id })?.id)
                            .environmentObject(exhibitionVM)
                    }
                } header: {
                    Text("Past")
                        .sectionHeaderBackground()
                }
                .sectionBackground()
                
            }
            .id("exhibitions-\(refreshCount)")
            .redacted(reason: isLoading ? .placeholder : [])
            .onFirstAppear {
                isLoading = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isLoading = false
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
            myExhibitionVM.updateSections(with: exhibitionVM.exhibitions)
        }
        .onChange(of: exhibitionVM.exhibitions) { _, newValue in
            myExhibitionVM.updateSections(with: newValue)
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
