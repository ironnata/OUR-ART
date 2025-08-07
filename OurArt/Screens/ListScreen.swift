//
//  ListScreen.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI

struct ListScreen: View {
    
    @StateObject private var viewModel = ExhibitionViewModel()
    
    @State var searchText = ""
    @State var isLoading: Bool = false
    @State private var isRefreshing = false
    
    @Binding var shouldScrollToTop: Bool
    
    func filterExhibitions() -> [Exhibition] {
        guard !searchText.isEmpty else {
            return viewModel.exhibitions
        }
        
        return viewModel.exhibitions.filter { exhibition in
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
        try? await viewModel.filterSelected(option: viewModel.selectedFilter ?? .noFilter)
        
        isRefreshing = false
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                ScrollViewReader { proxy in
                    ZStack {
                        List {
                            ForEach(filterExhibitions()) { exhibition in
                                ExhibitionCellViewBuilder(exhibitionId: exhibition.id, myExhibitionId: nil)
                                    .environmentObject(viewModel)
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
                        .refreshable {
                            await refreshData()
                        }
                        .onChange(of: shouldScrollToTop) { oldValue, newValue in
                            if newValue {
                                withAnimation {
                                    if let firstId = filterExhibitions().first?.id {
                                        proxy.scrollTo(firstId, anchor: .top)
                                    }
                                }
                                shouldScrollToTop = false
                            }
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
        }
        .onDisappear {
            viewModel.removeListenerForAllExhibitions()
        }
        .viewBackground()
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Text("Exhibitions")
                    .font(.objectivityTitle)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(ExhibitionViewModel.FilterOption.allCases, id: \.self) { option in
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
                    Image(systemName: viewModel.selectedFilter?.icon ?? "line.3.horizontal.decrease.circle")
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
