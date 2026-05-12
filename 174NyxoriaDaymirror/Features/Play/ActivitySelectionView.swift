//
//  ActivitySelectionView.swift
//  174NyxoriaDaymirror
//

import SwiftUI

struct ActivitySelectionView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    let activity: ActivityDefinition
    @State private var difficulty: GameDifficulty = .normal
    @State private var practiceMode = false

    private var adaptiveColumns: [GridItem] {
        let minW: CGFloat = progressStore.comfortableLayoutEnabled ? 124 : 108
        let maxW: CGFloat = progressStore.comfortableLayoutEnabled ? 188 : 168
        return [
            GridItem(.adaptive(minimum: minW, maximum: maxW), spacing: 14, alignment: .top)
        ]
    }

    var body: some View {
        ZStack {
            LayeredBackgroundView()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    difficultyPanel

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Levels")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                        Text("Choose a stage. Earn at least one star on a stage to open the next.")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    LazyVGrid(columns: adaptiveColumns, spacing: 14) {
                        ForEach(0 ..< ActivityDefinition.levelCount, id: \.self) { level in
                            let unlocked = progressStore.isLevelUnlocked(
                                activity: activity,
                                difficulty: difficulty,
                                levelIndex: level
                            )
                            let stars = progressStore.stars(activity: activity, difficulty: difficulty, level: level)
                            NavigationLink {
                                destination(for: level)
                            } label: {
                                LevelGatewayCell(
                                    levelNumber: level + 1,
                                    starsEarned: stars,
                                    unlocked: unlocked,
                                    practice: practiceMode
                                )
                            }
                            .buttonStyle(LevelCellButtonStyle())
                            .disabled(!unlocked)
                        }
                    }
                    Spacer(minLength: 48)
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(activity.title)
        .navigationBarTitleDisplayMode(.inline)
        .appChromeNavigationBar()
    }

    private var difficultyPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Difficulty")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            Picker("Difficulty", selection: $difficulty) {
                ForEach(GameDifficulty.allCases) { value in
                    Text(value.title).tag(value)
                }
            }
            .pickerStyle(.segmented)
            Toggle(isOn: $practiceMode) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Practice mode")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("No STARS saved, no unlocks. Timers still run for rehearsal.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .tint(Color.appPrimary)
            .padding(.top, 4)
            .onChange(of: practiceMode) { _ in
                HapticFeedback.buttonTap()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedPlate(cornerRadius: 20, elevation: .soft)
    }

    @ViewBuilder
    private func destination(for level: Int) -> some View {
        switch activity {
        case .petalHarmony:
            PetalHarmonyView(difficulty: difficulty, levelIndex: level, isPractice: practiceMode)
        case .petalPathway:
            PetalPathwayView(difficulty: difficulty, levelIndex: level, isPractice: practiceMode)
        case .chorusGrove:
            ChorusGroveView(difficulty: difficulty, levelIndex: level, isPractice: practiceMode)
        }
    }
}

// MARK: - Level cell

private struct LevelGatewayCell: View {
    let levelNumber: Int
    let starsEarned: Int
    let unlocked: Bool
    var practice: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appSurface.opacity(unlocked ? 0.98 : 0.72),
                            Color.appSurface.opacity(unlocked ? 0.88 : 0.58)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: unlocked
                            ? [Color.appAccent.opacity(0.75), Color.appPrimary.opacity(0.55)]
                            : [Color.appTextSecondary.opacity(0.28), Color.appTextSecondary.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: unlocked ? 2 : 1
                )

            if unlocked {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary.opacity(0.12), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .allowsHitTesting(false)
            }

            VStack(spacing: 12) {
                ZStack {
                    ForEach(0 ..< 3, id: \.self) { ring in
                        Circle()
                            .strokeBorder(
                                Color.appAccent.opacity(0.12 - Double(ring) * 0.03),
                                lineWidth: 1
                            )
                            .frame(width: 58 + CGFloat(ring) * 10, height: 58 + CGFloat(ring) * 10)
                    }
                    Text("\(levelNumber)")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundStyle(unlocked ? Color.appTextPrimary : Color.appTextSecondary)
                }
                .frame(height: 56)

                HStack(spacing: 5) {
                    ForEach(0 ..< 3, id: \.self) { index in
                        Image(systemName: index < starsEarned ? "star.fill" : "star")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(index < starsEarned ? Color.appPrimary : Color.appTextSecondary.opacity(0.32))
                    }
                }

                HStack(spacing: 6) {
                    if unlocked {
                        if practice {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.caption.weight(.semibold))
                            Text("Practice")
                                .font(.caption.weight(.bold))
                        } else {
                            Image(systemName: "leaf.fill")
                                .font(.caption.weight(.semibold))
                            Text("Play")
                                .font(.caption.weight(.bold))
                        }
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.caption.weight(.semibold))
                        Text("Locked")
                            .font(.caption.weight(.bold))
                    }
                }
                .foregroundStyle(unlocked ? Color.appAccent : Color.appTextSecondary)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 10)
            .opacity(unlocked ? 1 : 0.82)

            if !unlocked {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.appBackground.opacity(0.35))
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 132)
        .compositingGroup()
        .shadow(
            color: Color.black.opacity(unlocked ? 0.12 : 0.065),
            radius: unlocked ? 11 : 6,
            x: 0,
            y: unlocked ? 6 : 3
        )
    }
}

private struct LevelCellButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.38, dampingFraction: 0.72), value: configuration.isPressed)
    }
}
