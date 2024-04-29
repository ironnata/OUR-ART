//
//  MyExhibitionsView.swift
//  OurArt
//
//  Created by Jongmo You on 29.04.24.
//

import SwiftUI

@MainActor
final class MyExhibitionViewModel: ObservableObject {
    
    @Published private(set) var exhibitions: [(userMyExhibition: UserMyExhibition, exhibition: Exhibition)] = []
    
    func getMyExhibitions() {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            let userMyExhibitions = try await UserManager.shared.getAllMyExhibitions(userId: authDataResult.uid)
            
            var localArray: [(userMyExhibition: UserMyExhibition, exhibition: Exhibition)] = []
            for userMyExhibition in userMyExhibitions {
                if let exhibition = try? await ExhibitionManager.shared.getExhibition(id: userMyExhibition.exhibitionId) {
                    localArray.append((userMyExhibition, exhibition))
                }
            }
            
            self.exhibitions = localArray
        }
    }
    
    // Favorite 기능 넣으면 쓸 기능
    func removeMyExhibitions(myExhibitionId: String) {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            
            try? await UserManager.shared.removeMyExhibition(userId: authDataResult.uid, myExhibitionId: myExhibitionId)
            getMyExhibitions()
        }
    }
}

struct MyExhibitionsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = MyExhibitionViewModel()
    
    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.exhibitions, id: \.userMyExhibition.id.self) { item in
                    NavigationLink(destination: ExhibitionDetailView(exhibition: item.exhibition)) {
                        ExhibitionCellView(exhibition: item.exhibition)
                            .contextMenu(menuItems: {
                                Button("Remove from Favorites") {
                                    viewModel.removeMyExhibitions(myExhibitionId: item.userMyExhibition.id)
                                }
                            })
                    }
                }
                .sectionBackground()
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
        }
        .navigationTitle("My Exhibitions")
        .onAppear {
            viewModel.getMyExhibitions()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .onTapGesture {
                        dismiss()
                    }
            }
        }
        .viewBackground()
    }
}

#Preview {
    MyExhibitionsView()
}
