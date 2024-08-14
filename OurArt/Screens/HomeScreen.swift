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
    @State var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("""
Welcome to WE ART 🖌️ \n\(profileVM.user?.nickname ?? "")👋
""")
                        .lineSpacing(7)
                        .frame(height: 120)
                    
                    NavigationView {
                        ZStack {
                            Color.background0
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 10) {
                                    ForEach(exhibitionVM.exhibitions.shuffled()) { exhibition in
                                        NavigationLink(destination: ExhibitionDetailView(exhibition: exhibition)) {
                                            ExhibitionPosterView(exhibition: exhibition)
                                        }
                                    }
                                    .padding(.horizontal, 25)
                                    .padding(.bottom, 20)
                                    .redacted(reason: isLoading ? .placeholder : [])
                                    .onFirstAppear {
                                        isLoading = true
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            isLoading = false
                                        }
                                    }
                                }
                                .scrollTargetLayout()
                            }
                            .frame(height: 440)
                        }
                        .scrollTargetBehavior(.viewAligned)
                    }
                }
                .font(.objectivityTitle2)
            }
            .padding()
            .fullScreenCover(isPresented: $showAddingView) {
                NavigationView {
                    AddExhibitionFirstView(showAddingView: $showAddingView)
                        .onDisappear {
                            Task {
                                try? await profileVM.loadCurrentUser()
                                exhibitionVM.getExhibitions()
                            }
                        }
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    self.logoImageHome()
                }
            })
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    Text("Show yours to the world!")
                    Button {
                        withAnimation {
                            showAddingView.toggle()
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.largeTitle)
                    }
                    .padding()
                    .padding(.trailing, 20)
                }
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
