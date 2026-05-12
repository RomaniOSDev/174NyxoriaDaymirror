//
//  ChorusGroveView.swift
//  174NyxoriaDaymirror
//

import SwiftUI

struct ChorusGroveView: View {
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
        ChorusGroveGameSession(difficulty: difficulty, levelIndex: activeLevel, isPractice: isPractice) {
            activeLevel += 1
        }
        .id("\(difficulty.rawValue)-\(activeLevel)-\(isPractice)-\(sessionToken.uuidString)")
        .onReceive(NotificationCenter.default.publisher(for: .progressReset)) { _ in
            sessionToken = UUID()
        }
    }
}

private struct ChorusGroveGameSession: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss

    @StateObject private var model: ChorusGroveViewModel
    @State private var sheet: ChorusResultSheet?
    @State private var activePlantTouch: Int?
    @State private var isPausePresented = false
    private let isPractice: Bool
    private let onAdvanceLevel: () -> Void

    init(difficulty: GameDifficulty, levelIndex: Int, isPractice: Bool, onAdvanceLevel: @escaping () -> Void) {
        _model = StateObject(wrappedValue: ChorusGroveViewModel(difficulty: difficulty, levelIndex: levelIndex))
        self.isPractice = isPractice
        self.onAdvanceLevel = onAdvanceLevel
    }

    var body: some View {
        ZStack {
            LayeredBackgroundView()
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let wave = sin(t * 4.0) * 0.04 + 0.1
                    let rect = CGRect(
                        x: size.width * 0.5 - size.width * (0.22 + wave),
                        y: size.height * 0.18 - size.width * (0.22 + wave),
                        width: size.width * (0.44 + wave * 2),
                        height: size.width * (0.44 + wave * 2)
                    )
                    let ring = Path(ellipseIn: rect)
                    context.stroke(ring, with: .color(Color.appAccent.opacity(0.22)), lineWidth: 2)
                }
                .allowsHitTesting(false)
            }
            GeometryReader { proxy in
                let size = proxy.size
                ZStack {
                    ForEach(0 ..< 5, id: \.self) { index in
                        plantView(index: index, in: size)
                    }
                }
                .frame(width: size.width, height: size.height)
            }
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
                    Text(isPractice ? "Practice · Beat \(min(model.currentBeatIndex + 1, model.totalBeats)) / \(model.totalBeats)" : "Beat \(min(model.currentBeatIndex + 1, model.totalBeats)) / \(model.totalBeats)")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Streak Watch \(model.wrongStreak)/3")
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
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    model.useHint()
                } label: {
                    Image(systemName: "light.beacon.min.fill")
                        .foregroundStyle(Color.appPrimary)
                }
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
                activity: .chorusGrove,
                difficulty: model.difficulty,
                levelIndex: model.levelIndex,
                starsEarned: newValue.stars,
                playSeconds: model.playDurationSeconds,
                isPractice: isPractice
            )
            let newly = isPractice ? [] : achievementDelta(before: before)
            sheet = ChorusResultSheet(
                success: newValue.success,
                stars: newValue.stars,
                newlyUnlocked: newly,
                showNextLevel: !isPractice && newValue.success && model.levelIndex < ActivityDefinition.levelCount - 1,
                accuracySnapshot: newValue.accuracy
            )
            model.clearResolution()
        }
        .fullScreenCover(item: $sheet) { payload in
            GameResultView(
                isPractice: isPractice,
                success: payload.success,
                stars: payload.stars,
                primaryMetricTitle: "Accuracy",
                primaryMetricValue: String(format: "%.0f%%", payload.accuracySnapshot * 100),
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

    private func plantView(index: Int, in size: CGSize) -> some View {
        let center = plantCenter(for: index, in: size)
        let isTarget = model.currentBeatIndex < model.totalBeats && model.plantSequence.indices.contains(model.currentBeatIndex) && model.plantSequence[model.currentBeatIndex] == index
        let hintRing = model.hintFocusedPlant == index
        let glow = isTarget
        return ZStack {
            if hintRing {
                Circle()
                    .strokeBorder(Color.appPrimary.opacity(0.95), lineWidth: 3)
                    .frame(width: 104, height: 104)
            }
            Circle()
                .fill(Color.appSurface.opacity(0.95))
                .frame(width: 92, height: 92)
                .overlay {
                    Circle()
                        .strokeBorder(Color.appAccent.opacity(glow ? 0.95 : 0.25), lineWidth: glow ? 4 : 2)
                }
            Circle()
                .fill(Color.appPrimary.opacity(glow ? 0.55 : 0.18))
                .frame(width: 46, height: 46)
                .blur(radius: glow ? 8 : 0)
        }
        .position(center)
        .highPriorityGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !isPausePresented else { return }
                    if activePlantTouch == nil {
                        activePlantTouch = index
                        model.touchBegan(on: index, at: Date())
                    }
                }
                .onEnded { _ in
                    if activePlantTouch == index {
                        model.touchEnded(on: index, at: Date())
                    }
                    activePlantTouch = nil
                }
        )
    }

    private func plantCenter(for index: Int, in size: CGSize) -> CGPoint {
        let spots: [CGPoint] = [
            CGPoint(x: 0.14, y: 0.28),
            CGPoint(x: 0.38, y: 0.42),
            CGPoint(x: 0.62, y: 0.3),
            CGPoint(x: 0.82, y: 0.46),
            CGPoint(x: 0.48, y: 0.68)
        ]
        let spot = spots[index]
        return CGPoint(x: spot.x * size.width, y: spot.y * size.height)
    }

    private func achievementSnapshot() -> Set<AchievementKind> {
        Set(AchievementKind.allCases.filter { $0.isUnlocked(using: progressStore) })
    }

    private func achievementDelta(before: Set<AchievementKind>) -> [AchievementKind] {
        let after = achievementSnapshot()
        return Array(after.subtracting(before))
    }
}

private struct ChorusResultSheet: Identifiable {
    let id = UUID()
    let success: Bool
    let stars: Int
    let newlyUnlocked: [AchievementKind]
    let showNextLevel: Bool
    let accuracySnapshot: Double
}
