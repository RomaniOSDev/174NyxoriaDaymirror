//
//  AchievementsView.swift
//  174NyxoriaDaymirror
//

import SwiftUI

private extension AchievementKind {
    var badgeIcon: String {
        switch self {
        case .firstLight: return "sparkles"
        case .newbieGardener: return "leaf.fill"
        case .timeKeeper: return "clock.fill"
        case .starCollector: return "star.fill"
        case .levelUp: return "map.fill"
        case .starMaster: return "crown.fill"
        case .activePlayer: return "figure.walk"
        case .hundredPlays: return "flame.fill"
        }
    }
}

struct AchievementsView: View {
    @EnvironmentObject private var progressStore: ProgressStore

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    private var sortedKinds: [AchievementKind] {
        AchievementKind.allCases.sorted { a, b in
            let ua = a.isUnlocked(using: progressStore)
            let ub = b.isUnlocked(using: progressStore)
            if ua != ub { return ua && !ub }
            return a.title.localizedCaseInsensitiveCompare(b.title) == .orderedAscending
        }
    }

    private var unlockedCount: Int {
        AchievementKind.allCases.filter { $0.isUnlocked(using: progressStore) }.count
    }

    private let totalCount = AchievementKind.allCases.count

    var body: some View {
        ZStack {
            LayeredBackgroundView()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroHeader

                    Text("All rewards")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .padding(.horizontal, 4)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(sortedKinds) { achievement in
                            AchievementBadgeView(
                                kind: achievement,
                                title: achievement.title,
                                detail: achievement.detail,
                                unlocked: achievement.isUnlocked(using: progressStore)
                            )
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.large)
        .appChromeNavigationBar()
    }

    private var heroHeader: some View {
        let progress = Double(unlockedCount) / Double(max(totalCount, 1))
        return HStack(alignment: .center, spacing: 18) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.appAccent.opacity(0.35),
                                Color.appPrimary.opacity(0.12),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 4,
                            endRadius: 52
                        )
                    )
                    .frame(width: 100, height: 100)
                ZStack {
                    Circle()
                        .stroke(Color.appSurface.opacity(0.9), lineWidth: 8)
                        .frame(width: 88, height: 88)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color.appPrimary,
                                    Color.appAccent,
                                    Color.appPrimary
                                ],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 88, height: 88)
                        .rotationEffect(.degrees(-90))
                    Image(systemName: "medal.star.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.appAccent, Color.appPrimary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)

            VStack(alignment: .leading, spacing: 10) {
                Text("Trophy garden")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("\(unlockedCount) of \(totalCount) rewards earned")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.appBackground.opacity(0.45))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appPrimary, Color.appAccent.opacity(0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(12, proxy.size.width * progress))
                    }
                }
                .frame(height: 10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .appElevatedPlate(cornerRadius: 24, elevation: .lifted)
    }
}

private struct AchievementBadgeView: View {
    let kind: AchievementKind
    let title: String
    let detail: String
    let unlocked: Bool
    @State private var pulse = false
    @State private var previousUnlocked = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                if unlocked {
                    LinearGradient(
                        colors: [
                            Color.appPrimary.opacity(0.22),
                            Color.appAccent.opacity(0.14),
                            Color.appSurface.opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    LinearGradient(
                        colors: [
                            Color.appTextSecondary.opacity(0.12),
                            Color.appSurface.opacity(0.55),
                            Color.appBackground.opacity(0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        unlocked ? AppGradients.surfaceRim : AppGradients.surfaceRimMuted,
                        lineWidth: unlocked ? 1.25 : 1
                    )

                VStack(spacing: 10) {
                    ZStack {
                        Image(systemName: kind.badgeIcon)
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(
                                unlocked
                                    ? AnyShapeStyle(
                                        LinearGradient(
                                            colors: [Color.appPrimary, Color.appAccent],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    : AnyShapeStyle(Color.appTextSecondary.opacity(0.35))
                            )
                            .scaleEffect(unlocked && pulse ? 1.06 : 1)
                            .animation(
                                .spring(response: 0.45, dampingFraction: 0.55).repeatCount(3, autoreverses: true),
                                value: pulse
                            )

                        if !unlocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.appTextSecondary.opacity(0.55))
                                .padding(8)
                                .background {
                                    Circle()
                                        .fill(Color.appSurface.opacity(0.95))
                                        .overlay {
                                            Circle()
                                                .strokeBorder(Color.appTextSecondary.opacity(0.2), lineWidth: 1)
                                        }
                                }
                                .offset(x: 36, y: -32)
                        }
                    }
                    .frame(height: 52)

                    if unlocked {
                        Text("Unlocked")
                            .font(.caption2.weight(.heavy))
                            .tracking(0.8)
                            .foregroundStyle(Color.appBackground)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background {
                                Capsule()
                                    .fill(AppGradients.primaryButtonFill)
                                    .overlay {
                                        Capsule()
                                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.75)
                                    }
                            }
                    } else {
                        Text("Locked")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.appTextSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background {
                                Capsule()
                                    .fill(Color.appSurface.opacity(0.85))
                                    .overlay {
                                        Capsule()
                                            .strokeBorder(Color.appTextSecondary.opacity(0.25), lineWidth: 1)
                                    }
                            }
                    }
                }
                .padding(.vertical, 14)
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .appElevatedPlate(cornerRadius: 22, elevation: unlocked ? .soft : .muted, mutedRim: !unlocked)
        .opacity(unlocked ? 1 : 0.72)
        .onAppear {
            previousUnlocked = unlocked
        }
        .onChange(of: unlocked) { newValue in
            if newValue, newValue != previousUnlocked {
                HapticFeedback.starEarned()
                pulse = true
            }
            previousUnlocked = newValue
        }
    }
}
