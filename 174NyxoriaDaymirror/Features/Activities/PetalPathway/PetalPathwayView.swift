//
//  PetalPathwayView.swift
//  174NyxoriaDaymirror
//

import SwiftUI

struct PetalPathwayView: View {
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
        PetalPathwayGameSession(difficulty: difficulty, levelIndex: activeLevel, isPractice: isPractice) {
            activeLevel += 1
        }
        .id("\(difficulty.rawValue)-\(activeLevel)-\(isPractice)-\(sessionToken.uuidString)")
        .onReceive(NotificationCenter.default.publisher(for: .progressReset)) { _ in
            sessionToken = UUID()
        }
    }
}

private struct PetalPathwayGameSession: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss

    @StateObject private var model: PetalPathwayViewModel
    @State private var sheet: PathwayResultSheet?
    @State private var isPausePresented = false
    private let isPractice: Bool
    private let onAdvanceLevel: () -> Void

    init(difficulty: GameDifficulty, levelIndex: Int, isPractice: Bool, onAdvanceLevel: @escaping () -> Void) {
        _model = StateObject(wrappedValue: PetalPathwayViewModel(difficulty: difficulty, levelIndex: levelIndex))
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
                        let scaled = model.pathPoints.map { CGPoint(x: $0.x * canvasSize.width, y: $0.y * canvasSize.height) }
                        var path = Path()
                        if let first = scaled.first {
                            path.move(to: first)
                            for point in scaled.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                        context.stroke(path, with: .color(Color.appAccent.opacity(0.65)), lineWidth: 4)
                    }
                    .allowsHitTesting(false)

                    ForEach(Array(model.flowerPositions(in: size).enumerated()), id: \.offset) { index, center in
                        let bloomed = index < model.pollinatedCount
                        let hintHere = model.hintNextBloomIndex == index
                        Circle()
                            .fill(Color.appPrimary.opacity(bloomed ? 0.85 : 0.25))
                            .frame(width: bloomed ? 34 : 22, height: bloomed ? 34 : 22)
                            .overlay {
                                Circle().stroke(Color.appAccent.opacity(hintHere ? 1 : 0.8), lineWidth: hintHere ? 4 : (bloomed ? 3 : 1))
                            }
                            .position(center)
                            .animation(.spring(response: 0.45, dampingFraction: 0.72), value: model.pollinatedCount)
                    }

                    let creaturePoint = model.positionAlongPath(progress: model.creatureProgress, in: size)
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppGradients.surfacePlate)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(AppGradients.surfaceRim, lineWidth: 1)
                        }
                        .frame(width: 46, height: 36)
                        .overlay {
                            Image(systemName: "waveform.path.ecg")
                                .foregroundStyle(Color.appPrimary)
                                .font(.caption.weight(.bold))
                        }
                        .compositingGroup()
                        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                        .position(creaturePoint)
                }
                .contentShape(Rectangle())
                .highPriorityGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard !isPausePresented else { return }
                            let location = value.location
                            let normalized = CGPoint(x: location.x / max(size.width, 1), y: location.y / max(size.height, 1))
                            model.drag(to: normalized, in: size)
                        }
                )
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
                    Text(isPractice ? "Practice · Time \(Int(max(model.timeRemaining, 0)))s" : "Time Left \(Int(max(model.timeRemaining, 0)))s")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Flowers \(model.pollinatedCount)/\(model.flowerStops.count)")
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
                activity: .petalPathway,
                difficulty: model.difficulty,
                levelIndex: model.levelIndex,
                starsEarned: newValue.stars,
                playSeconds: model.playDurationSeconds,
                isPractice: isPractice
            )
            let newly = isPractice ? [] : achievementDelta(before: before)
            sheet = PathwayResultSheet(
                success: newValue.success,
                stars: newValue.stars,
                newlyUnlocked: newly,
                showNextLevel: !isPractice && newValue.success && model.levelIndex < ActivityDefinition.levelCount - 1,
                elapsedSnapshot: newValue.elapsed
            )
            model.clearResolution()
        }
        .fullScreenCover(item: $sheet) { payload in
            GameResultView(
                isPractice: isPractice,
                success: payload.success,
                stars: payload.stars,
                primaryMetricTitle: "Elapsed",
                primaryMetricValue: String(format: "%.1fs", payload.elapsedSnapshot),
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

    private func achievementSnapshot() -> Set<AchievementKind> {
        Set(AchievementKind.allCases.filter { $0.isUnlocked(using: progressStore) })
    }

    private func achievementDelta(before: Set<AchievementKind>) -> [AchievementKind] {
        let after = achievementSnapshot()
        return Array(after.subtracting(before))
    }
}

private struct PathwayResultSheet: Identifiable {
    let id = UUID()
    let success: Bool
    let stars: Int
    let newlyUnlocked: [AchievementKind]
    let showNextLevel: Bool
    let elapsedSnapshot: Double
}
