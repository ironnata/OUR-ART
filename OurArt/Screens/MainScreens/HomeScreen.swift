//
//  HomeScreen.swift
//  OurArt
//
//  Created by Jongmo You on 12.10.23.
//

import SwiftUI

struct HomeScreen: View {
    
    @State var showAddingView = false
    
    var body: some View {
        VStack {
            Text("Home")
            Button {
                showAddingView.toggle()
            } label: {
                Image(systemName: "plus.circle")
            }
        }
        .sheet(isPresented: $showAddingView) {
            NavigationView {
                AddExhibitionFirstView(showAddingView: $showAddingView)
            }
        }
    }
}

#Preview {
    HomeScreen()
}
