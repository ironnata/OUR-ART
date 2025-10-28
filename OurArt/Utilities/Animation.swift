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

struct HeartAnimationValues {
    var scale = 1.0
    var verticalStretch = 1.0
    var verticalTranslation = 0.0
    var angle = Angle.zero
}
