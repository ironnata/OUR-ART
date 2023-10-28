//
//  ContentView.swift
//  OurArt
//
//  Created by Jongmo You on 11.10.23.
//

import SwiftUI

struct ContentView: View {
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        TabView {
            NavigationView {
                HomeScreen()
                    .navigationTitle("Home")
            }.tag(0)
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            
            NavigationView {
                ListScreen()
                    .navigationTitle("List")
            }.tag(1)
            .tabItem {
                Image(systemName: "list.dash")
                Text("List")
            }
            
            NavigationView {
                SettingsScreen(showSignInView: $showSignInView)
                    .navigationTitle("Settings")
            }.tag(2)
            .tabItem {
                Image(systemName: "gearshape.2")
                Text("Settings")
            }
            
        }
    }
}

#Preview {
    ContentView(showSignInView: .constant(false))
}
