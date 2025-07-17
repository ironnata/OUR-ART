//
//  Haptic.swift
//  OurArt
//
//  Created by Jongmo You on 17.07.25.
//

import Foundation
import UIKit

struct Haptic {
    private init() {} // 인스턴스화 방지

    @available(iOS 10.0, *)
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    @available(iOS 10.0, *)
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    @available(iOS 10.0, *)
    static func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
