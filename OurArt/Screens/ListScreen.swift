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
                    NavigationLink(destination: ExhibitionDetailView(exhibition: exhibition)) {
                        ExhibitionCellView(exhibition: exhibition)
                            .contextMenu(menuItems: {
                                Button("Add to Favorites") {
                                    // Favorite func 만들어서 변경
//                                    viewModel.addUserMyExhibition(exhibitionId: exhibition.id)
                                }
                            })
                    }
                    .redacted(reason: isLoading ? .placeholder : [])
                    .onFirstAppear {
                        isLoading = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isLoading = false
                        }
                    }
                    
//                    if exhibition == viewModel.exhibitions.last {
//                        HStack(alignment: .center) {
//                            Spacer()
//                            ProgressView()
//                                .onAppear {
//                                    viewModel.getExhibitions()
//                            }
//                            Spacer()
//                        }
//                    }
                }
                .sectionBackground()
                .listRowSeparator(.hidden)
            }
            .toolbarBackground()
            .refreshable {
                try? await Task.sleep(nanoseconds: 900_000_000)
                viewModel.addListenerForAllExhibitions()
            }
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
            .onAppear {
                viewModel.addListenerForAllExhibitions()
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
