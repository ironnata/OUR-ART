//
//  ContentView.swift
//  OurArt
//
//  Created by Jongmo You on 11.10.23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            ListScreen()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("List")
                }
            
            SettingsScreen()
                .tabItem {
                    Image(systemName: "gearshape.2")
                    Text("Settings")
                }
            
        }
    }
}

#Preview {
    ContentView()
}
