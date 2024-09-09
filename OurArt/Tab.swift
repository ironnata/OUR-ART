//
//  Tab.swift
//  OurArt
//
//  Created by Jongmo You on 24.08.24.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case home = "globe"
    case list = "list.dash"
    case settings = "gearshape"
}

struct AnimatedTab: Identifiable {
    var id: UUID = .init()
    var tab: Tab
    var isAnimating: Bool?
}
