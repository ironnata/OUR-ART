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
    @StateObject private var favoriteVM = FavoriteExhibitionViewModel()
    @StateObject private var exhibitionVM = ExhibitionViewModel()
    
    @State private var isLoading: Bool = false
    @State private var isRefreshing = false
    @State private var refreshCount = 0
    
    let placeholderImage = Image("Tech and Innovation _ rocket, launch, takeoff, Vector illustration")
    
    private func addListeners() {
        favoriteVM.addListenerForAllUserFavorites()
        myExhibitionVM.addListenerForMyExhibitions()
        exhibitionVM.addListenerForAllExhibitions()
    }
    
    private func removeListeners() {
        favoriteVM.removeListenerForAllUserFavorites()
        myExhibitionVM.removeListenerForMyExhibitions()
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
    
    private var favoriteIds: Set<String> {
        Set(favoriteVM.favExhibitions.map { $0.exhibitionId })
    }
    
    var body: some View {
        ZStack {
            if myExhibitionVM.myOngoingOrUpcoming.isEmpty && myExhibitionVM.myPast.isEmpty {
                VStack(alignment: .center, spacing: 10) {
                    placeholderImage
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: UIScreen.main.bounds.height * 0.3)
                        .padding(.top, 20)
                    
                    Text("Create your first dot")
                    
                    Spacer()
                }
                .foregroundStyle(Color.secondAccent)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .sectionBackground()
            } else {
                List {
                    Section {
                        ForEach(myExhibitionVM.myOngoingOrUpcoming) { exhibition in
                            let isFavorited = favoriteIds.contains(exhibition.id)
                            ExhibitionCellViewBuilder(exhibitionId: exhibition.id, myExhibitionId: myExhibitionVM.userMyExhibitions.first(where: { $0.exhibitionId == exhibition.id })?.id, favExhibitionId: nil)
                                .environmentObject(exhibitionVM)
                                .overlay {
                                    HStack {
                                        Spacer()
                                        
                                        if isFavorited {
                                            Image(systemName: "heart.fill")
                                        }
                                    }
                                    .padding()
                                }
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
                            let isFavorited = favoriteIds.contains(exhibition.id)
                            ExhibitionCellViewBuilder(exhibitionId: exhibition.id, myExhibitionId: myExhibitionVM.userMyExhibitions.first(where: { $0.exhibitionId == exhibition.id })?.id, favExhibitionId: nil)
                                .environmentObject(exhibitionVM)
                                .overlay {
                                    HStack {
                                        Spacer()
                                        
                                        if isFavorited {
                                            Image(systemName: "heart.fill")
                                                .foregroundStyle(.secondAccent)
                                        }
                                    }
                                    .padding()
                                }
                        }
                    } header: {
                        if myExhibitionVM.myPast.isEmpty {
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
        }
        .viewBackground()
        .onAppear {
            addListeners()
            myExhibitionVM.updateSections(with: exhibitionVM.exhibitions)
        }
        .onChange(of: exhibitionVM.exhibitions) { _, newValue in
            myExhibitionVM.updateSections(with: newValue)
        }
        .onDisappear {
            removeListeners()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("My Exhibitions")
                    .font(.objectivityTitle3)
            }
            
            ToolbarBackButton()
        }
    }
}

