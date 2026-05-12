//
//  HapticFeedback.swift
//  174NyxoriaDaymirror
//

import UIKit

enum HapticFeedback {
    static func buttonTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func majorAction() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func starEarned() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func failure() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func successBanner() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
