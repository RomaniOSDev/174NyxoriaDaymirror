//
//  GameResultView.swift
//  174NyxoriaDaymirror
//

import SwiftUI

struct GameResultView: View {
    var isPractice: Bool = false
    let success: Bool
    let stars: Int
    let primaryMetricTitle: String
    let primaryMetricValue: String
    let newlyUnlocked: [AchievementKind]
    let showNextLevel: Bool
    let onNextLevel: () -> Void
    let onRetry: () -> Void
    let onBackToLevels: () -> Void

    @State private var revealedStars = 0
    @State private var bannerOffset: CGFloat = -260
    @State private var flashOpacity: Double = 0

    var body: some View {
        ZStack {
            LayeredBackgroundView()
            ScrollView {
                VStack(spacing: 22) {
                    if isPractice {
                        Text("Practice session")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appAccent)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .appElevatedPlate(cornerRadius: 12, elevation: .muted)
                    }
                    if success {
                        successHeader
                    } else {
                        failHeader
                    }

                    if success {
                        HStack(spacing: 10) {
                            ForEach(0 ..< 3, id: \.self) { index in
                                let filled = index < revealedStars && index < stars
                                Image(systemName: filled ? "star.fill" : "star")
                                    .font(.system(size: 40, weight: .bold))
                                    .scaleEffect(filled ? 1 : 0.35)
                                    .opacity(filled ? 1 : 0.55)
                                    .animation(.spring(response: 0.45, dampingFraction: 0.68), value: revealedStars)
                            }
                        }
                        .padding(.top, 6)
                    } else {
                        HStack(spacing: 10) {
                            ForEach(0 ..< 3, id: \.self) { index in
                                Image(systemName: "star")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(Color.appTextSecondary.opacity(0.35))
                            }
                        }
                    }

                    VStack(spacing: 8) {
                        Text(primaryMetricTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appTextSecondary)
                        Text(primaryMetricValue)
                            .font(.system(size: 44, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.appTextPrimary)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(18)
                    .appElevatedPlate(cornerRadius: 18, elevation: .lifted)

                    if !newlyUnlocked.isEmpty, !isPractice {
                        achievementBanner
                            .offset(y: bannerOffset)
                    }

                    VStack(spacing: 12) {
                        if success, showNextLevel, !isPractice {
                            Button {
                                HapticFeedback.buttonTap()
                                onNextLevel()
                            } label: {
                                Text("Next Level")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryProminentButtonStyle())
                        }

                        if success {
                            Button {
                                HapticFeedback.buttonTap()
                                onRetry()
                            } label: {
                                Text("Retry")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SurfaceOutlineButtonStyle())
                        } else {
                            Button {
                                HapticFeedback.buttonTap()
                                onRetry()
                            } label: {
                                Text("Try Again")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryProminentButtonStyle())
                        }

                        Button {
                            HapticFeedback.buttonTap()
                            onBackToLevels()
                        } label: {
                            Text("Back to Levels")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SurfaceOutlineButtonStyle())
                    }
                    .padding(.top, 8)

                    Spacer(minLength: 40)
                }
                .padding(20)
            }

            if !success {
                Color.red.opacity(flashOpacity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            if success {
                HapticFeedback.successBanner()
                SystemSounds.playSuccess()
                revealedStars = 0
                for index in 0 ..< max(stars, 0) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.68)) {
                            revealedStars = index + 1
                        }
                    }
                }
                if !newlyUnlocked.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 2)) {
                            bannerOffset = 0
                        }
                    }
                }
            } else {
                HapticFeedback.failure()
                SystemSounds.playFail()
                withAnimation(.easeInOut(duration: 0.3)) {
                    flashOpacity = 0.6
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        flashOpacity = 0
                    }
                }
            }
        }
    }

    private var successHeader: some View {
        VStack(spacing: 8) {
            Text("Wonderful!")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            Text("Your garden responded with joy.")
                .font(.headline)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var failHeader: some View {
        VStack(spacing: 8) {
            Text("Keep Going")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            Text("The garden needs a softer touch.")
                .font(.headline)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var achievementBanner: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("New Achievement")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appBackground)
            Text(newlyUnlocked.map(\.title).joined(separator: ", "))
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.appBackground)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppGradients.primaryButtonFill)
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppGradients.topGleam)
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.75)
            }
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.14), radius: 12, x: 0, y: 7)
        }
    }
}
