//
//  PauseOverlayView.swift
//  174NyxoriaDaymirror
//

import SwiftUI

struct PauseOverlayView: View {
    let onResume: () -> Void
    let onQuit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.52)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Paused")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("Timers and rhythm wait until you continue.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                Button {
                    HapticFeedback.buttonTap()
                    onResume()
                } label: {
                    Text("Resume")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryProminentButtonStyle())
                Button {
                    HapticFeedback.buttonTap()
                    onQuit()
                } label: {
                    Text("Quit to Levels")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SurfaceOutlineButtonStyle())
            }
            .padding(24)
            .appElevatedPlate(cornerRadius: 22, elevation: .floating)
            .padding(28)
        }
    }
}
