//
//  ListScreen.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI

struct ListScreen: View {
    
    @StateObject private var viewModel = ExhibitionViewModel()
    @StateObject private var favoriteVM = FavoriteExhibitionViewModel()
    
    @State var searchText = ""
    @State var isLoading: Bool = false
    @State private var isRefreshing = false
    
    @State private var showPastSection = false
    
    private var favIdMap: [String: String] {
        favoriteVM.favExhibitions.reduce(into: [:]) { $0[$1.exhibitionId] = $1.id }
    }

    private var favoriteIds: Set<String> {
        Set(favoriteVM.favExhibitions.map { $0.exhibitionId })
    }
    
    @Binding var shouldScrollToTop: Bool
    
    func filterExhibitions() -> [Exhibition] {
        guard !searchText.isEmpty else {
            return viewModel.ongoingOrUpcoming + viewModel.past
        }
        
        return (viewModel.ongoingOrUpcoming + viewModel.past).filter { exhibition in
            if let title = exhibition.title {
                return title.localizedCaseInsensitiveContains(searchText)
            }
            return false
        }
    }
    
    // 새로고침 함수
    private func refreshData() async {
        isRefreshing = true
        
        try? await Task.sleep(for: .seconds(0.8))
        try? await viewModel.filterSelected(option: viewModel.selectedFilter ?? .newest)
        
        isRefreshing = false
    }
    
    private var topTargetId: String? {
        viewModel.ongoingOrUpcoming.first?.id ?? viewModel.past.first?.id
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                ScrollViewReader { proxy in
                    ZStack {
                        List {
                            if !searchText.isEmpty {
                                ForEach(filterExhibitions()) { exhibition in
                                    let favId = favIdMap[exhibition.id]
                                    
                                    ExhibitionCellViewBuilder(exhibitionId: exhibition.id, myExhibitionId: nil, favExhibitionId: favId)
                                        .environmentObject(viewModel)
                                }
                                .sectionBackground()
                            } else {
                                Section {
                                    ForEach(viewModel.ongoingOrUpcoming) { exhibition in
                                        let favId = favIdMap[exhibition.id]
                                        let isFavorited = favoriteIds.contains(exhibition.id)
                                        
                                        ExhibitionCellViewBuilder(exhibitionId: exhibition.id, myExhibitionId: nil, favExhibitionId: favId)
                                            .environmentObject(viewModel)
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
                                    if viewModel.ongoingOrUpcoming.isEmpty {
                                        EmptyView()
                                    } else {
                                        Text("Ongoing / Upcoming")
                                            .sectionHeaderBackground()                                        
                                    }
                                }
                                .sectionBackground()
                                
                                
                                if showPastSection {
                                    Section {
                                        ForEach(viewModel.past) { exhibition in
                                            let favId = favIdMap[exhibition.id]
                                            let isFavorited = favoriteIds.contains(exhibition.id)
                                            
                                            ExhibitionCellViewBuilder(exhibitionId: exhibition.id, myExhibitionId: nil, favExhibitionId: favId)
                                                .environmentObject(viewModel)
                                                .overlay {
                                                    HStack {
                                                        Spacer()
                                                        
                                                        Image(systemName: isFavorited ? "heart.fill" : "")
                                                            .foregroundStyle(.secondAccent)
                                                    }
                                                    .padding()
                                                }
                                        }
                                    } header: {
                                        Text("Past")
                                            .sectionHeaderBackground()
                                    }
                                    .sectionBackground()
                                }
                            }
                        }
                        .refreshable {
                            await refreshData()
                        }
                        .onChange(of: shouldScrollToTop) { _, newValue in
                            guard newValue, let id = topTargetId else { return }
                            withAnimation { proxy.scrollTo(id, anchor: .top) }
                            shouldScrollToTop = false
                        }
                        .toolbarBackground()
                        .listStyle(.plain)
                        .searchable(
                            text: $searchText,
                            placement: .automatic,
                            prompt: "Search"
                        )
                    }
                }
            }
        }
        .task {
            viewModel.addListenerForAllExhibitions()
            favoriteVM.addListenerForAllUserFavorites()
        }
        .onDisappear {
            viewModel.removeListenerForAllExhibitions()
            favoriteVM.removeListenerForAllUserFavorites()
        }
        .viewBackground()
        .toolbar(content: {
//            ToolbarItem(placement: .topBarLeading) {
//                Text("Exhibitions")
//                    .font(.objectivityTitle2)
//            }
            CompatibleToolbarItem(placement: .topBarLeading) {
                Text("Exhibitions")
                    .font(.objectivityTitle2)
                    .frame(width: 150, alignment: .leading)
            }
            
            
            CompatibleToolbarItem(placement: .topBarTrailing) {
                Button {
                    showPastSection.toggle()
                } label: {
                    if showPastSection {
                        Image(systemName: "archivebox.circle.fill")
                    } else {
                        Image(systemName: "archivebox.circle")
                    }
                }
            }
            
            CompatibleToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(ExhibitionViewModel.SortOption.allCases, id: \.self) { option in
                        Button {
                            Task {
                                try? await viewModel.filterSelected(option: option)
                            }
                        } label: {
                            Text(option.rawValue)
                            Image(systemName: option.icon ?? "")
                        }
                    }
                } label: {
                    Image(systemName: viewModel.selectedFilter?.icon ?? "arrow.down.to.line.circle")
                }
            }
            
            // CATEGORY 추가 시 사용
            //            ToolbarItem(placement: .topBarTrailing) {
            //                Menu("\(viewModel.categorySelected?.rawValue ?? "") \(Image(systemName: "square.grid.2x2"))") {
            //                    ForEach(ExhibitionViewModel.CategoryOption.allCases, id: \.self) { option in
            //                        Button(option.rawValue) {
            //                            Task {
            //                                try? await viewModel.categorySelected(option: option)
            //                            }
            //                        }
            //                    }
            //                }
            //            }
        })
        
        // CATEGORY 추가 시 사용
        //        .onAppear(
        //            try? await viewModel.getExhibitions()
        //        )
    }
}

#Preview {
    NavigationStack {
        ListScreen(shouldScrollToTop: .constant(false))
    }
}
