//
//  PetalHarmonyView.swift
//  174NyxoriaDaymirror
//

import SwiftUI

struct PetalHarmonyView: View {
    let difficulty: GameDifficulty
    let isPractice: Bool
    @State private var activeLevel: Int
    @State private var sessionToken = UUID()

    init(difficulty: GameDifficulty, levelIndex: Int, isPractice: Bool = false) {
        self.difficulty = difficulty
        self.isPractice = isPractice
        _activeLevel = State(initialValue: levelIndex)
    }

    var body: some View {
        PetalHarmonyGameSession(difficulty: difficulty, levelIndex: activeLevel, isPractice: isPractice) {
            activeLevel += 1
        }
        .id("\(difficulty.rawValue)-\(activeLevel)-\(isPractice)-\(sessionToken.uuidString)")
        .onReceive(NotificationCenter.default.publisher(for: .progressReset)) { _ in
            sessionToken = UUID()
        }
    }
}

private struct PetalHarmonyGameSession: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss

    @StateObject private var model: PetalHarmonyViewModel
    @State private var sheet: HarmonyResultSheet?
    @State private var isPausePresented = false
    private let isPractice: Bool
    private let onAdvanceLevel: () -> Void

    init(difficulty: GameDifficulty, levelIndex: Int, isPractice: Bool, onAdvanceLevel: @escaping () -> Void) {
        _model = StateObject(wrappedValue: PetalHarmonyViewModel(difficulty: difficulty, levelIndex: levelIndex))
        self.isPractice = isPractice
        self.onAdvanceLevel = onAdvanceLevel
    }

    var body: some View {
        ZStack {
            LayeredBackgroundView()
            GeometryReader { proxy in
                let size = proxy.size
                ZStack {
                    Canvas { context, canvasSize in
                        let now = Date()
                        for ripple in model.ripples {
                            let age = now.timeIntervalSince(ripple.created)
                            let radius = CGFloat(age) * 220
                            let rect = CGRect(
                                x: ripple.position.x * canvasSize.width - radius,
                                y: ripple.position.y * canvasSize.height - radius,
                                width: radius * 2,
                                height: radius * 2
                            )
                            let circle = Path(ellipseIn: rect)
                            context.stroke(circle, with: .color(Color.appAccent.opacity(0.45 - age * 0.45)), lineWidth: 3)
                        }
                    }
                    .allowsHitTesting(false)

                    ForEach(Array(model.plantPositions().enumerated()), id: \.offset) { index, point in
                        plantView(index: index, point: point, in: size)
                    }

                    if let sparkle = model.sparklePoint {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.appPrimary.opacity(0.95), Color.appPrimary.opacity(0.35)],
                                    center: .center,
                                    startRadius: 2,
                                    endRadius: 16
                                )
                            )
                            .frame(width: 26, height: 26)
                            .position(x: sparkle.x * size.width, y: sparkle.y * size.height)
                            .shadow(color: Color.appAccent.opacity(0.35), radius: 5, y: 0)
                    }
                }
                .contentShape(Rectangle())
                .highPriorityGesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            guard !isPausePresented else { return }
                            let location = value.location
                            let normalized = CGPoint(x: location.x / max(size.width, 1), y: location.y / max(size.height, 1))
                            model.handleTap(at: normalized, in: size)
                        }
                )
            }
            .opacity(1 - model.gardenDim * 0.85)

            if isPausePresented {
                PauseOverlayView(
                    onResume: {
                        isPausePresented = false
                        model.setPaused(false)
                    },
                    onQuit: {
                        isPausePresented = false
                        model.setPaused(false)
                        dismiss()
                    }
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(isPractice ? "Practice · Score \(model.score)" : "Score \(model.score)")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Survive \(Int(min(model.survivalTime, 60))) / 60s · Combo \(model.combo)")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    HapticFeedback.buttonTap()
                    model.setPaused(true)
                    isPausePresented = true
                } label: {
                    Image(systemName: "pause.fill")
                        .foregroundStyle(Color.appAccent)
                }
                .accessibilityLabel("Pause")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    model.useHint()
                } label: {
                    Image(systemName: "light.beacon.min.fill")
                        .foregroundStyle(Color.appPrimary)
                }
                .accessibilityLabel("Hint")
            }
        }
        .appChromeNavigationBar()
        .onAppear {
            model.start()
        }
        .onDisappear {
            model.stop()
        }
        .onChange(of: model.resolution) { newValue in
            guard let newValue else { return }
            guard sheet == nil else { return }
            let before = achievementSnapshot()
            progressStore.recordSessionOutcome(
                activity: .petalHarmony,
                difficulty: model.difficulty,
                levelIndex: model.levelIndex,
                starsEarned: newValue.stars,
                playSeconds: model.playDurationSeconds,
                isPractice: isPractice
            )
            let newly = isPractice ? [] : achievementDelta(before: before)
            sheet = HarmonyResultSheet(
                success: newValue.success,
                stars: newValue.stars,
                newlyUnlocked: newly,
                showNextLevel: !isPractice && newValue.success && model.levelIndex < ActivityDefinition.levelCount - 1
            )
            model.clearResolution()
        }
        .fullScreenCover(item: $sheet) { payload in
            GameResultView(
                isPractice: isPractice,
                success: payload.success,
                stars: payload.stars,
                primaryMetricTitle: "Score",
                primaryMetricValue: "\(model.score)",
                newlyUnlocked: payload.newlyUnlocked,
                showNextLevel: payload.showNextLevel,
                onNextLevel: {
                    HapticFeedback.majorAction()
                    sheet = nil
                    onAdvanceLevel()
                },
                onRetry: {
                    HapticFeedback.buttonTap()
                    sheet = nil
                    model.start()
                },
                onBackToLevels: {
                    HapticFeedback.buttonTap()
                    sheet = nil
                    dismiss()
                }
            )
        }
    }

    private func plantView(index: Int, point: CGPoint, in size: CGSize) -> some View {
        let center = CGPoint(x: point.x * size.width, y: point.y * size.height)
        let isGlowing = model.glowingIndex == index
        let hintHere = model.hintPulsePlantIndex == index
        return ZStack {
            if hintHere {
                Circle()
                    .strokeBorder(Color.appPrimary.opacity(0.9), lineWidth: 3)
                    .frame(width: 100, height: 100)
            }
            Circle()
                .fill(Color.appSurface.opacity(0.95))
                .frame(width: 86, height: 86)
                .overlay {
                    Circle()
                        .strokeBorder(Color.appAccent.opacity(isGlowing ? 0.95 : 0.25), lineWidth: isGlowing ? 4 : 2)
                }
            Circle()
                .fill(Color.appPrimary.opacity(isGlowing ? 0.55 : 0.18))
                .frame(width: 44, height: 44)
                .blur(radius: isGlowing ? 6 : 0)
        }
        .position(center)
    }

    private func achievementSnapshot() -> Set<AchievementKind> {
        Set(AchievementKind.allCases.filter { $0.isUnlocked(using: progressStore) })
    }

    private func achievementDelta(before: Set<AchievementKind>) -> [AchievementKind] {
        let after = achievementSnapshot()
        return Array(after.subtracting(before))
    }
}

private struct HarmonyResultSheet: Identifiable {
    let id = UUID()
    let success: Bool
    let stars: Int
    let newlyUnlocked: [AchievementKind]
    let showNextLevel: Bool
}
