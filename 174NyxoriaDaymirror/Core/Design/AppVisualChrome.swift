//
//  AppVisualChrome.swift
//  174NyxoriaDaymirror
//
//  Shared elevation, gradients, and navigation chrome. Static gradients + one shadow
//  per plate — avoids stacking multiple .shadow modifiers on scrolling content.
//

import SwiftUI

// MARK: - Gradients (all static — no TimelineView)

enum AppGradients {
    static let backdropBase = LinearGradient(
        colors: [
            Color.appBackground,
            Color.appSurface.opacity(0.76),
            Color.appBackground.opacity(0.94)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Plate fill — vertical “lit from above” illusion.
    static let surfacePlate = LinearGradient(
        colors: [
            Color.appSurface.opacity(0.99),
            Color.appSurface.opacity(0.82)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Edge rim against the backdrop.
    static let surfaceRim = LinearGradient(
        colors: [
            Color.white.opacity(0.12),
            Color.appAccent.opacity(0.28),
            Color.appPrimary.opacity(0.15)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let surfaceRimMuted = LinearGradient(
        colors: [
            Color.white.opacity(0.06),
            Color.appTextSecondary.opacity(0.2)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let topGleam = LinearGradient(
        colors: [
            Color.white.opacity(0.11),
            Color.clear
        ],
        startPoint: .top,
        endPoint: .center
    )

    static let bottomShade = LinearGradient(
        colors: [
            Color.clear,
            Color.black.opacity(0.045)
        ],
        startPoint: .center,
        endPoint: .bottom
    )

    static let primaryButtonFill = LinearGradient(
        colors: [
            Color.appPrimary,
            Color.appPrimary.opacity(0.74)
        ],
        startPoint: .top,
        endPoint: .bottomTrailing
    )

    static let chromeTabShell = LinearGradient(
        colors: [
            Color.appSurface.opacity(0.99),
            Color.appSurface.opacity(0.9)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let chromeTabStroke = LinearGradient(
        colors: [
            Color.white.opacity(0.16),
            Color.appAccent.opacity(0.28)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let tabSelectionFill = LinearGradient(
        colors: [
            Color.appPrimary,
            Color.appPrimary.opacity(0.76)
        ],
        startPoint: .top,
        endPoint: .bottomTrailing
    )

    /// Navigation bar / chrome strip (cheap — no blur).
    static let navigationWash = LinearGradient(
        colors: [
            Color.appSurface.opacity(0.58),
            Color.appSurface.opacity(0.34)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Shadow tiers

enum AppCardElevation: Sendable {
    /// List rows and dense grids.
    case muted
    /// Default cards (settings, guides).
    case soft
    /// Hero blocks and gateways.
    case lifted
    /// Tab bar shell, pause panel.
    case floating

    fileprivate var spec: (radius: CGFloat, y: CGFloat, opacity: CGFloat) {
        switch self {
        case .muted: return (8, 3, 0.09)
        case .soft: return (11, 5, 0.11)
        case .lifted: return (14, 7, 0.14)
        case .floating: return (22, 10, 0.2)
        }
    }
}

// MARK: - Elevated plates

private struct ElevatedPlateBackground: View {
    var cornerRadius: CGFloat = 18
    var elevation: AppCardElevation = .soft
    var rimMuted: Bool = false

    var body: some View {
        let s = elevation.spec
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppGradients.surfacePlate)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(rimMuted ? AppGradients.surfaceRimMuted : AppGradients.surfaceRim, lineWidth: 1)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppGradients.topGleam)
                .allowsHitTesting(false)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppGradients.bottomShade)
                .allowsHitTesting(false)
        }
        .compositingGroup()
        .shadow(color: Color.black.opacity(s.opacity), radius: s.radius, x: 0, y: s.y)
    }
}

extension View {

    /// Card / panel styling: gradient fill + rim highlight + single shadow.
    func appElevatedPlate(
        cornerRadius: CGFloat = 18,
        elevation: AppCardElevation = .soft,
        mutedRim: Bool = false
    ) -> some View {
        background {
            ElevatedPlateBackground(cornerRadius: cornerRadius, elevation: elevation, rimMuted: mutedRim)
        }
    }

    func appChromeNavigationBar() -> some View {
        toolbarBackground(AppGradients.navigationWash, for: .navigationBar)
    }
}
