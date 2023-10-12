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
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            
            NavigationView {
                ListScreen()
                    .navigationTitle("List")
            }
            .tabItem {
                Image(systemName: "list.dash")
                Text("List")
            }
            
            NavigationView {
                SettingsScreen(showSignInView: $showSignInView)
                    .navigationTitle("Settings")
            }
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
