//
//  ContentView.swift
//  OurArt
//
//  Created by Jongmo You on 11.10.23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selection = 0
    
    var handler: Binding<Int> { Binding(
            get: { self.selection },
            set: {
                if $0 == self.selection {
                    print("Reset here!!")
                }
                self.selection = $0
            }
        )}
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                HomeScreen()
            }.tag(0)
            .tabItem {
                Image(systemName: "house")
            }
            
            NavigationView {
                ListScreen()
            }.tag(1)
            .tabItem {
                Image(systemName: "list.dash")
            }
            
            NavigationView {
                SettingsScreen(showSignInView: $showSignInView)
            }.tag(2)
            .tabItem {
                Image(systemName: "gearshape.2")
            }
        }
    }
}

#Preview {
    ContentView(showSignInView: .constant(false))
}
