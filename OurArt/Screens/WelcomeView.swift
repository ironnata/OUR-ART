//
//  WelcomeView.swift
//  OurArt
//
//  Created by Jongmo You on 15.05.25.
//

import SwiftUI

struct WelcomePage {
    let imageName: String
    let title: String
    let subtitle: String
}

let welcomePages: [WelcomePage] = [
    WelcomePage(imageName: "Health and Wellness _ counseling, mental health, therapy, stress relief, support, Vector illustration", title: "Dot's where art connects", subtitle: "Art spaces made by people like you"),
    WelcomePage(imageName: "Avatars and Characters _ celebrity, pop art, actress, faces, icons", title: "A world behind every dot", subtitle: "Find exhibitions, curated by all kinds of creators"),
    WelcomePage(imageName: "Health and Wellness _ body, pain, massage, treatment, Vector illustration", title: "Tiny dots, big worlds inside", subtitle: "Start your journey — create, explore, connect")
]

struct WelcomeView: View {
    @Binding var showWelcomeView: Bool
    
    @State private var startingAnimation = false
    @State private var onTapAnimation = false
    @State private var hasShownButton = false
    @State private var currentIndex = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Spacer()
                    
                    TabView(selection: $currentIndex) {
                        ForEach(0..<welcomePages.count, id: \.self) { index in
                            let page = welcomePages[index]
                            VStack {
                                Spacer()
                                
                                Image(page.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7)
                                    .clipShape(.rect(cornerRadius: 12, style: .continuous))
                                    .padding(.bottom, 30)
                                
                                Text(page.title)
                                    .font(.objectivityTitle3)
                                    .foregroundStyle(Color.accent)
                                
                                Text(page.subtitle)
                                    .lineSpacing(7)
                                    .font(.objectivityBody)
                                    .foregroundStyle(Color.accent)
                                    .frame(height: 60)
                                    .padding(.bottom, 20)
                            }
                            .tag(index)
                            .padding()
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(maxWidth: .infinity)
                    
                    // 페이지 인디케이터
                    CustomTabIndicator(count: welcomePages.count, current: $currentIndex)
                    
                    Button {
                        withAnimation {
                            showWelcomeView = false
                        }
                    } label: {
                        Text("Jump in!".uppercased())
                    }
                    .modifier(CommonButtonModifier())
                    .padding()
                    .opacity(hasShownButton ? 1 : 0)
                    .animation(.easeInOut(duration: 0.7), value: hasShownButton)
                }
            }
            .viewBackground()
            .onChange(of: currentIndex) { _, newValue in
                if newValue == 2 {
                    hasShownButton = true
                }
            }
        }
    }
}

#Preview {
    WelcomeView(showWelcomeView: .constant(true))
}

struct CustomTabIndicator: View {
    var count: Int
    @Binding var current: Int
    
    var body: some View {
        HStack {
            ForEach(0..<count, id: \.self) { index in
                ZStack {
                    if current == index {
                        Circle()
                            .fill(Color.accent)
                            .frame(width: 8, height: 8)
                            .overlay {
                                Circle()
                                    .stroke(Color.accent, lineWidth: 1.5)
                            }
                    } else {
                        Circle()
                            .fill(Color.secondAccent)
                            .frame(width: 8, height: 8)
                        
                    }
                }
            }
        }
    }
}
