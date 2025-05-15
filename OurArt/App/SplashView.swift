//
//  SplashView.swift
//  OurArt
//
//  Created by Jongmo You on 07.05.25.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.launchScreenBackground.edgesIgnoringSafeArea(.all)
            Image("LaunchScreenLogo")
        }
    }
}

#Preview {
    SplashView()
}
