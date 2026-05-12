//
//  AppButtonStyles.swift
//  174NyxoriaDaymirror
//

import SwiftUI

struct PrimaryProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.appBackground)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppGradients.primaryButtonFill)
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppGradients.topGleam)
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.75)
                }
                .compositingGroup()
                .shadow(color: Color.black.opacity(0.16), radius: 10, x: 0, y: 5)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct SurfaceOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.appTextPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppGradients.surfacePlate)
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AppGradients.surfaceRim, lineWidth: 1)
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppGradients.topGleam)
                }
                .compositingGroup()
                .shadow(color: Color.black.opacity(0.09), radius: 9, x: 0, y: 4)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct DestructiveOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.red.opacity(0.95))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppGradients.surfacePlate)
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.red.opacity(0.55), Color.red.opacity(0.25)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.25
                        )
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppGradients.topGleam)
                }
                .compositingGroup()
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
