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
    
}

struct ListScreen: View {
    var body: some View {
        
        List(0 ..< 7) { item in
            ExhibitionCellView(title: "Awesome", poster: "IMG_3245 2")
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ListScreen()
    }
}
