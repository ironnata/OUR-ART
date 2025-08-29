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
    
    @State private var isUploaded = false
    @State private var successUploadBanner = false
    
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
            .fullScreenCover(isPresented: $showAddingView, onDismiss: {
                if isUploaded {
                    withAnimation(.spring(response: 0.3)) {
                        successUploadBanner = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.spring(response: 0.3)) {
                            isUploaded = false
                            successUploadBanner = false
                            
                        }
                    }
                }
            }) {
                NavigationView {
                    AddExhibitionFirstView(showAddingView: $showAddingView, isUploaded: $isUploaded)
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
                            withAnimation(.easeInOut(duration: 0.25), completionCriteria: .logicallyComplete) {
                                isRotating = true
                                rotation = 90
                                animationAmount -= 0.3
                            } completion: {
                                // 1) 시트를 먼저 띄움 (버튼이 아직 돌아오기 전)
                                var tx = Transaction()
                                tx.disablesAnimations = true
                                withTransaction(tx) { showAddingView = true }

                                // 2) 아주 짧게 텀을 두고 복귀 애니메이션 시작
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    withAnimation(.easeInOut(duration: 0.25), completionCriteria: .logicallyComplete) {
                                        isRotating = false
                                        rotation = 0
                                        animationAmount = 1
                                    } completion: {
                                        
                                    }
                                }
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
            
            if successUploadBanner {
                VStack {
                    BannerMessage(text: "Your dot is live!")
                    Spacer()
                }
                .padding(.top, 100)
            }
        }
        .viewBackground()
    }
}

#Preview {
    HomeScreen()
}
