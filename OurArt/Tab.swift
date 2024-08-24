//
//  Tab.swift
//  OurArt
//
//  Created by Jongmo You on 24.08.24.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case home = "house"
    case list = "list.dash"
    case settings = "gearshape.2"
}

struct AnimatedTab: Identifiable {
    var id: UUID = .init()
    var tab: Tab
    var isAnimating: Bool?
}
