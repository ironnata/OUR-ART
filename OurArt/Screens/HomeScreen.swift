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
                    let messages: [String] = [
                                                 """
                                                 Hello, \(profileVM.user?.nickname ?? "")! 😁 \nNice to see you today
                                                 """,
                                                 """
                    Hi, \(profileVM.user?.nickname ?? "")! 😄 \nHow are you doing?
                    """,
                                                 "How's it going today, \(profileVM.user?.nickname ?? "")? 😀",
                                                 """
Hey \(profileVM.user?.nickname ?? "")! \nIt's time to explore the world of art 🎨
""",
                                                 """
Welcome to WE, ART 🖌️ \n\(profileVM.user?.nickname ?? "")
"""
                    ]
                    
                    Text(messages.randomElement() ?? "Hi there👋")
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
                                    .padding(.horizontal, 12)
                                    .padding(.bottom, 20)
                                }
                                //                            .scrollTargetLayout() ~iOS17~
                            }
                            .frame(height: 440)
                        }
                        //                        .scrollTargetBehavior(.paging) iOS17~
                    }
                }
                .font(.objectivityTitle2)
            }
            .padding()
            .fullScreenCover(isPresented: $showAddingView) {
                NavigationView {
                    AddExhibitionFirstView(showAddingView: $showAddingView)
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    Image("Logo-512")
                        .resizable()
                        .frame(width: 57, height: 57)
                        .cornerRadius(9)
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
