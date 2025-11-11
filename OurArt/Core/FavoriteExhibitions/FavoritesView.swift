//
//  FavoritesView.swift
//  OurArt
//
//  Created by Jongmo You on 30.10.25.
//

import SwiftUI

struct FavoritesView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var favoriteVM = FavoriteExhibitionViewModel()
    @StateObject private var exhibitionVM = ExhibitionViewModel()
    
    @State private var isLoading: Bool = false
    @State private var isRefreshing = false
    @State private var refreshCount = 0
    
    private func addListeners() {
        favoriteVM.addListenerForAllUserFavorites()
        exhibitionVM.addListenerForAllExhibitions()
    }
    
    private func removeListeners() {
        favoriteVM.removeListenerForAllUserFavorites()
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
            if favoriteVM.favOngoingOrUpcoming.isEmpty && favoriteVM.favPast.isEmpty {
                VStack(alignment: .center, spacing: 10) {
                    Image("Avatars and Characters _ celebrity, pop art, actress, faces, icons")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.height * 0.3)
                        .padding(.top, 20)
                    
                    Text("Collect your favorites here")
                    
                    Spacer()
                }
                .foregroundStyle(Color.secondAccent)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .sectionBackground()
                
            } else {
                List {
                    Section {
                        ForEach(favoriteVM.favOngoingOrUpcoming) { exhibition in
                            ExhibitionCellViewBuilder(exhibitionId: exhibition.id, myExhibitionId: nil, favExhibitionId: favoriteVM.favExhibitions.first(where: { $0.exhibitionId == exhibition.id })?.id)
                                .environmentObject(exhibitionVM)
                        }
                    } header: {
                        if favoriteVM.favOngoingOrUpcoming.isEmpty {
                            EmptyView()
                        } else {
                            Text("Ongoing / Upcoming")
                                .sectionHeaderBackground()
                        }
                    }
                    .sectionBackground()
                    
                    Section {
                        ForEach(favoriteVM.favPast) { exhibition in
                            ExhibitionCellViewBuilder(exhibitionId: exhibition.id, myExhibitionId: nil, favExhibitionId: favoriteVM.favExhibitions.first(where: { $0.exhibitionId == exhibition.id })?.id)
                                .environmentObject(exhibitionVM)
                        }
                    } header: {
                        if favoriteVM.favPast.isEmpty {
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
                }
                .toolbarBackground()
                .listStyle(.plain)
            }
        }
        .viewBackground()
        .onAppear {
            addListeners()
            favoriteVM.updateSections(with: exhibitionVM.exhibitions)
        }
        .onChange(of: exhibitionVM.exhibitions) { _, newValue in
            favoriteVM.updateSections(with: newValue)
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
