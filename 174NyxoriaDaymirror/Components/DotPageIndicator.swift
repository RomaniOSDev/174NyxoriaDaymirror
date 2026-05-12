//
//  DotPageIndicator.swift
//  174NyxoriaDaymirror
//

import SwiftUI

struct DotPageIndicator: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< count, id: \.self) { index in
                Group {
                    if index == current {
                        Capsule()
                            .fill(AppGradients.tabSelectionFill)
                            .overlay {
                                Capsule()
                                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.75)
                            }
                            .frame(width: 28, height: 9)
                            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                    } else {
                        Circle()
                            .fill(Color.appSurface.opacity(0.75))
                            .overlay {
                                Circle()
                                    .strokeBorder(Color.appTextSecondary.opacity(0.35), lineWidth: 1)
                            }
                            .frame(width: 9, height: 9)
                    }
                }
                .animation(.spring(response: 0.42, dampingFraction: 0.74), value: current)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(current + 1) of \(count)")
    }
}
