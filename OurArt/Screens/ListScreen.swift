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
    
    var body: some View {
        
        ZStack {
            List {
                ForEach(filterExhibitions()) { exhibition in
                    NavigationLink(destination: ExhibitionDetailView(exhibition: exhibition, myExhibitionId: nil)) {
                        ExhibitionCellView(exhibition: exhibition)
                            .contextMenu(menuItems: {
                                Button("Add to Favorites") {
                                    // Favorite func 만들어서 변경
                                    viewModel.addUserMyExhibition(exhibitionId: exhibition.id)
                                }
                                // 테스트 용 삭제버튼
                                Button("Delete") {
                                    Task {
                                        try? await viewModel.deleteExhibition()
                                    }
                                }
                            })
                    }
                    
                    if exhibition == viewModel.exhibitions.last {
                        ProgressView()
                            .onAppear {
                                viewModel.getExhibitions()
                            }
                    }
                }
                .sectionBackground()
                .listRowSeparator(.hidden)
            }
            .toolbarBackground(.background0, for: .tabBar, .automatic)
            .toolbar(content: {
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
            .onAppear {
                viewModel.getExhibitions()
            }
            
            // CATEGORY 추가 시 사용
            //        .onAppear(
            //            try? await viewModel.getExhibitions()
            //        )
            
            .listStyle(.plain)
            
            // NavigationBar 안 검색창 UI
            .searchable(
                text: $searchText,
                placement: .automatic,
                prompt: "Search..."
            )
        }
        .viewBackground()
    }
}

#Preview {
    NavigationStack {
        ListScreen()
    }
}
