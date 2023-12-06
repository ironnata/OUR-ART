//
//  ListScreen.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI

@MainActor
final class ExhibitionViewModel: ObservableObject {
    
    @Published private(set) var exhibitions: [Exhibition] = []
    
    func getAllExhibitions() async throws {
        self.exhibitions = try await ExhibitionManager.shared.getAllExhibitions()
    }
    
    func createExhibition(exhibition: Exhibition) async throws {
        try await ExhibitionManager.shared.createExhibition(exhibition: exhibition)
    }
    
    
}

struct ListScreen: View {
    
    @StateObject private var viewModel = ExhibitionViewModel()
    
    var body: some View {
        
        List {
            ForEach(viewModel.exhibitions) { exhibition in
                NavigationLink(destination: ExhibitionDetailView(exhibition: exhibition)) {
                    ExhibitionCellView(exhibition: exhibition)
                }
            }
            .listRowSeparator(.hidden)
        }
        .task {
            try? await viewModel.getAllExhibitions()
        }
        .listStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ListScreen()
    }
}
