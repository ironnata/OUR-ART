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
    @State private var shuffledExhibitions: [Exhibition] = []
    
    @State private var isRotating: Bool = false
    @State private var rotation: Double = 0
    @State private var animationAmount: CGFloat = 1
    
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("""
Welcome to DOT. \n\(profileVM.user?.nickname ?? "")👋
""")
                        .lineSpacing(7)
                        .frame(height: 100)
                    
                    NavigationView {
                        ZStack {
                            Color.background0
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 10) {
                                    ForEach(shuffledExhibitions) { exhibition in
                                        NavigationLink(destination: ExhibitionDetailView(exhibitionId: exhibition.id)) {
                                            ExhibitionPosterView(exhibition: exhibition)
                                        }
                                    }
                                    .padding(.horizontal, 25)
                                    .padding(.bottom, 20)
                                    .redacted(reason: isLoading ? .placeholder : [])
                                    .onFirstAppear {
                                        isLoading = true
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                if let preferences = profileVM.user?.preferences, preferences.contains("Artist") {
                    HStack(spacing: -10) {
                        Text("Drop your dot on the world")
                            .font(.objectivityCallout)
                            .animation(.easeInOut(duration: 0.5))
                            .scaleEffect(animationAmount)
                            .opacity(isRotating ? 0 : 1)
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                isRotating = true
                                rotation = 90
                                self.animationAmount -= 0.3
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                showAddingView.toggle()
                                isRotating = false
                                rotation = 0
                                self.animationAmount = 1
                            }
                        } label: {
                            Image(systemName: "plus.circle")
                                .font(.title)
                                .rotationEffect(.degrees(rotation))
                        }
                        .padding()
                        .padding(.trailing, 20)
                    }
                }
            }
            .task {
                try? await profileVM.loadCurrentUser()
            }
            .onAppear {
                exhibitionVM.addListenerForAllExhibitions()
            }
            .onChange(of: exhibitionVM.exhibitions) { _, newExhibitions in
                shuffledExhibitions = newExhibitions.shuffled()
            }
        }
        .viewBackground()
    }
}

#Preview {
    HomeScreen()
}
