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
    
    let placeholderImage = Image(systemName: "person.circle.fill")
    
    @State var showAddingView = false
    @State var isLoading: Bool = false
    @State private var shuffledExhibitions: [Exhibition] = []
    
    @State private var isRotating: Bool = false
    @State private var rotation: Double = 0
    @State private var animationAmount: CGFloat = 1
    
    @State private var isUploaded = false
    @State private var successUploadBanner = false
    
    @State private var dragOffset: CGSize = .zero
    @State private var topPosterIndex: Int = 0
    
    var width: CGFloat = 280
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        let threshold: CGFloat = 50
        let direction: CGFloat = value.translation.width > 0 ? 1 : -1
        let delay = direction < 0 ? 0.18 : 0.20
        
        if abs(value.translation.width) > threshold {
            withAnimation(.smooth(duration: 0.2)) {
                dragOffset.width = direction < 0 ? -width * 1.5 : width * 1.5
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.smooth(duration: 0.5)) {
                    topPosterIndex = (topPosterIndex + 1) % shuffledExhibitions.count
                    dragOffset = .zero
                }
            }
        } else {
            withAnimation {
                dragOffset = .zero
            }
        }
    }
    
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .center) {
                    //                    Text("""
                    //Welcome to DOT. \n\(profileVM.user?.nickname ?? "")👋
                    //""")
                    //                        .lineSpacing(10)
                    //                        .frame(height: 100)
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color.redacted)
                        
                        HStack {
                            Text("Hello \(profileVM.user?.nickname ?? "")")
                            
                            Spacer()
                            
                            if let urlString = profileVM.user?.profileImagePathUrl, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .modifier(SmallProfileImageModifer())
                                } placeholder: {
                                    placeholderImage
                                        .resizable()
                                        .modifier(SmallProfileImageModifer())
                                        .foregroundStyle(Color.secondAccent)
                                }
                                .padding(.trailing, 30)
                            } else {
                                placeholderImage
                                    .resizable()
                                    .modifier(SmallProfileImageModifer())
                                    .foregroundStyle(Color.secondAccent)
                                    .padding(.trailing, 30)
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                    .frame(maxHeight: 100)
                    
                    Spacer()
                    
                    ZStack {
                        ForEach(shuffledExhibitions.prefix(10).indices, id: \.self) { index in
                            
                            let visualIndex = (index - topPosterIndex + shuffledExhibitions.count) % shuffledExhibitions.count
                            
                            CardView(
                                exhibition: shuffledExhibitions[index],
                                visualIndex: visualIndex,
                                dragOffset: dragOffset,
                                width: width,
                                count: shuffledExhibitions.count,
                                onDragChanged: { value in
                                    dragOffset = value.translation
                                },
                                onDragEnded: { value in
                                    handleDragEnded(value)
                                }
                            )
                            .zIndex(Double(shuffledExhibitions.count - visualIndex))
                            .id(shuffledExhibitions[index].id)
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
                        .frame(maxHeight: 440)
                    }
                    Spacer()
                }
                .font(.objectivityTitle3)
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
                CompatibleToolbarItem(placement: .topBarLeading) {
                    self.logoImageHome()
                }
                
                CompatibleToolbarItem(placement: .topBarTrailing) {
                    if let preferences = profileVM.user?.preferences, preferences.contains("Artist") {
                        HStack(spacing: -10) {
//                            Text("Drop your dot on the world")
//                                .font(.objectivityCallout)
//                                .animation(.easeInOut(duration: 0.5))
//                                .scaleEffect(animationAmount)
//                                .opacity(isRotating ? 0 : 1)
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.25), completionCriteria: .logicallyComplete) {
                                    isRotating = true
                                    rotation = 90
                                    animationAmount -= 0.3
                                } completion: {
                                    showAddingView = true

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation(.easeInOut(duration: 0.25), completionCriteria: .logicallyComplete) {
                                            isRotating = false
                                            rotation = 0
                                            animationAmount = 1
                                        } completion: {
                                            
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title3)
                                    .rotationEffect(.degrees(rotation))
                            }
                        }
                    }
                }
            })
            .task {
                try? await profileVM.loadCurrentUser()
            }
            .onAppear {
                exhibitionVM.addListenerForAllExhibitions()
            }
            .onDisappear {
                exhibitionVM.removeListenerForAllExhibitions()
            }
            .onChange(of: exhibitionVM.exhibitions) { _, newExhibitions in
                let shuffled = newExhibitions.shuffled()
                    shuffledExhibitions = Array(shuffled.prefix(10))
                // 이거 셔플버튼으로 만들어서 쓰자
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


struct CardView: View {
    let exhibition: Exhibition
    let visualIndex: Int
    let dragOffset: CGSize
    let width: CGFloat
    let count: Int
    
    @GestureState private var isDragging: Bool = false
    
    var onDragChanged: (DragGesture.Value) -> Void
    var onDragEnded: (DragGesture.Value) -> Void
    
    var body: some View {
        let progress = min(abs(dragOffset.width) / 150, 1)
        let signedProgress = (dragOffset.width >= 0 ? 1 : -1) * progress
        
        NavigationLink(destination: ExhibitionDetailView(exhibitionId: exhibition.id)) {
            ExhibitionPosterView(exhibition: exhibition)
                .frame(width: width, height: 420)
                .offset(x: visualIndex == 0 ? dragOffset.width : Double(visualIndex) * 10,
                        y: visualIndex == 0 ? 0 : Double(visualIndex) * -4)
            
                .rotationEffect(.degrees(visualIndex == 0 ? 0 : Double(visualIndex) * 3 - progress * 3), anchor: .bottom)
                .scaleEffect(visualIndex == 0 ? 1.0 : visualIndex == 1 ? (1.0 - Double(visualIndex) * 0.06 + progress * 0.06) : (1.0 - Double(visualIndex) * 0.06))
                .offset(x: visualIndex == 0 ? 0 : Double(visualIndex) * -1)
                .rotation3DEffect(.degrees((visualIndex == 0 || visualIndex == 1) ? 10 * signedProgress : 0), axis: (0, 1, 0))
        }
        .disabled(isDragging)
        .simultaneousGesture(
            DragGesture(minimumDistance: 10)
                .updating($isDragging) { value, gestureState, _ in
                    gestureState = true // 드래그 중일 때 gestureState를 true로 설정
                }
                .onChanged(onDragChanged)
                .onEnded(onDragEnded)
        )
    }
}
