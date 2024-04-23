//
//  HomeScreen.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI

struct HomeScreen: View {
    
    @StateObject private var profileVM = ProfileViewModel()
    @StateObject private var exhibitionVM = ExhibitionViewModel()
    
    @State var showAddingView = false
    
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("""
                         Hello, \(profileVM.user?.nickname ?? "")! \nNice to see you today :)
                         """)
                    .padding(.top, 20)
                    
                    NavigationView {
                        ZStack {
                            Color.background0
                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 10) {
                                    ForEach(exhibitionVM.exhibitions.shuffled()) { exhibition in
                                        NavigationLink(destination: ExhibitionDetailView(exhibition: exhibition)) {
                                            ExhibitionPosterView(exhibition: exhibition)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                }
    //                            .scrollTargetLayout() ~iOS17~
                            }
                            .frame(height: 400)
                        }
//                        .scrollTargetBehavior(.paging) iOS17~
                    }
                    
                }
                .font(.objectivityTitle2)
            }
            .padding()
            .padding(.top, 20)
            .fullScreenCover(isPresented: $showAddingView) {
                NavigationView {
                    AddExhibitionFirstView(showAddingView: $showAddingView)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    showAddingView.toggle()
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.largeTitle)
                }
                .padding()
                .padding(.trailing, 20)
            }
            .task {
                try? await profileVM.loadCurrentUser()
                exhibitionVM.getExhibitions()
            }
        }
        .viewBackground()
    }
}

#Preview {
    HomeScreen()
}
