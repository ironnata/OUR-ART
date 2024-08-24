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
        MainScreen(showSignInView: $showSignInView)
    }
}

#Preview {
    ContentView(showSignInView: .constant(false))
}
