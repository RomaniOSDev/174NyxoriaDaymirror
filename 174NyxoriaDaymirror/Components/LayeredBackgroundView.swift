//
//  LayeredBackgroundView.swift
//  174NyxoriaDaymirror
//

import SwiftUI

struct LayeredBackgroundView: View {
    var body: some View {
        ZStack {
            AppGradients.backdropBase

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.appPrimary.opacity(0.22),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: w * 0.48
                            )
                        )
                        .frame(width: w * 0.95, height: w * 0.95)
                        .position(x: w * 0.82, y: h * 0.12)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.appAccent.opacity(0.16),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: w * 0.38
                            )
                        )
                        .frame(width: w * 0.75, height: w * 0.75)
                        .position(x: w * 0.12, y: h * 0.58)
                }
                .allowsHitTesting(false)
            }

            DecorativeGridCanvas()
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

/// Lightweight line pattern; rasterised once-per-layout via `drawingGroup` (no animation).
private struct DecorativeGridCanvas: View {
    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                let spacing: CGFloat = 34
                var path = Path()
                var y: CGFloat = 0
                while y < size.height + spacing {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y + size.width * 0.07))
                    y += spacing
                }
                context.stroke(path, with: .color(Color.appAccent.opacity(0.065)), lineWidth: 1)

                for gx in stride(from: 0, to: Int(size.width), by: 72) {
                    let slice = CGFloat(gx + 36)
                    let h = max(size.height * 0.06, 6)
                    let rect = CGRect(x: slice - 1, y: size.height * 0.92, width: 2, height: h)
                    context.fill(Path(ellipseIn: rect), with: .color(Color.appPrimary.opacity(0.045)))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .drawingGroup(opaque: false)
    }
}
