//
//  FavoritesView.swift
//  OurArt
//
//  Created by Jongmo You on 30.10.25.
//

import SwiftUI

struct FavoritesView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var favExhibitionVM = FavoriteExhibitionViewModel()
    @StateObject private var exhibitionVM = ExhibitionViewModel()
    
    @State private var isLoading: Bool = false
    @State private var isRefreshing = false
    @State private var refreshCount = 0
    
    private func addListeners() {
        favExhibitionVM.addListenerForAllUserFavorites()
        exhibitionVM.addListenerForAllExhibitions()
    }
    
    private func removeListeners() {
        favExhibitionVM.removeListenerForAllUserFavorites()
        exhibitionVM.removeListenerForAllExhibitions()
    }
    
    private func refreshData() async {
        isRefreshing = true
        
        try? await Task.sleep(for: .seconds(0.8))
        
        // exhibitionVM의 리스너 재설정
        removeListeners()
        
        addListeners()
        
        refreshCount += 1
        isRefreshing = false
    }
    
    var body: some View {
        ZStack {
            List {
                Section {
                    ForEach(favExhibitionVM.favOngoingOrUpcoming) { exhibition in
                        ExhibitionCellViewBuilder(exhibitionId: exhibition.id, myExhibitionId: nil, favExhibitionId: favExhibitionVM.favExhibitions.first(where: { $0.exhibitionId == exhibition.id })?.id)
                            .environmentObject(exhibitionVM)
                    }
                } header: {
                    if favExhibitionVM.favOngoingOrUpcoming.isEmpty {
                        EmptyView()
                    } else {
                        Text("Ongoing / Upcoming")
                            .sectionHeaderBackground()
                    }
                }
                .sectionBackground()
                
                Section {
                    ForEach(favExhibitionVM.favPast) { exhibition in
                        ExhibitionCellViewBuilder(exhibitionId: exhibition.id, myExhibitionId: nil, favExhibitionId: favExhibitionVM.favExhibitions.first(where: { $0.exhibitionId == exhibition.id })?.id)
                            .environmentObject(exhibitionVM)
                    }
                } header: {
                    if favExhibitionVM.favPast.isEmpty {
                        EmptyView()
                    } else {
                        Text("Past")
                            .sectionHeaderBackground()
                    }
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
            addListeners()
            favExhibitionVM.updateSections(with: exhibitionVM.exhibitions)
        }
        .onChange(of: exhibitionVM.exhibitions) { _, newValue in
            favExhibitionVM.updateSections(with: newValue)
        }
        .onDisappear {
            removeListeners()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("My Favorites")
                    .font(.objectivityTitle3)
            }
            
            ToolbarBackButton()
        }
    }
}
