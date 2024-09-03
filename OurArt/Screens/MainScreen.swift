//
//  MainScreen.swift
//  OurArt
//
//  Created by Jongmo You on 24.08.24.
//

import SwiftUI

struct MainScreen: View {
    @State private var activeTab: Tab = .home
    
    @State private var allTabs: [AnimatedTab] = Tab.allCases.compactMap { Tab -> AnimatedTab? in
        return .init(tab: Tab)
    }
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $activeTab) {
                NavigationView {
                    HomeScreen()
                }
                .setUpTab(.home)
                
                NavigationView {
                    ListScreen()
                        .id(activeTab == .list ? UUID() : nil)
                }
                .setUpTab(.list)
                
                NavigationView {
                    SettingsScreen(showSignInView: $showSignInView)
                }
                .setUpTab(.settings)
                
            }
            
            CustomTabBar()
        }
    }
    
    @ViewBuilder
    func CustomTabBar() ->  some View {
        HStack(spacing: 0) {
            ForEach($allTabs) { $animatedTab in
                let tab = animatedTab.tab
                
                VStack {
                    Image(systemName: tab.rawValue)
                        .font(.title2)
                        .symbolEffect(.bounce.byLayer.down, value: animatedTab.isAnimating)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(activeTab == tab ? Color.accent : Color.secondAccent.opacity(0.7))
                .padding(.top, 15)
                .padding(.bottom, 10)
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation(.bouncy, completionCriteria: .logicallyComplete) {
                        activeTab = tab
                        animatedTab.isAnimating = true
                    } completion: {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            animatedTab.isAnimating = false
                        }
                    }
                }
            }
        }
        .viewBackground()
    }
}

#Preview {
    MainScreen(showSignInView: .constant(false))
}
