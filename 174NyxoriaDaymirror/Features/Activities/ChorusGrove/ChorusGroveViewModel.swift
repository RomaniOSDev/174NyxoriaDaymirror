//
//  ChorusGroveViewModel.swift
//  174NyxoriaDaymirror
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class ChorusGroveViewModel: ObservableObject {
    struct Resolution: Identifiable, Equatable {
        let id = UUID()
        let success: Bool
        let stars: Int
        let accuracy: Double
    }

    let difficulty: GameDifficulty
    let levelIndex: Int

    @Published private(set) var currentBeatIndex: Int = 0
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var plantSequence: [Int] = []
    @Published private(set) var pulseDurations: [TimeInterval] = []
    @Published private(set) var successes: Int = 0
    @Published private(set) var wrongStreak: Int = 0
    @Published private(set) var resolution: Resolution?

    @Published private(set) var isPaused = false
    @Published private(set) var hintFocusedPlant: Int?
    private var hintConsumedThisSession = false

    private var timer: AnyCancellable?
    private var sessionStart = Date()
    private var pressPlant: Int?
    private var pressBeganAt: Date?
    private var beatClosed: [Bool] = []

    private let beatSpacing: TimeInterval = 1.0

    private var timingTolerance: TimeInterval {
        switch difficulty {
        case .easy: return 0.5
        case .normal: return 0.3
        case .hard: return 0.15
        }
    }

    /// Scales gently with level so late stages stay playable (was 6 + levelIndex * 2).
    var totalBeats: Int {
        let minB = 6
        let maxB = 28
        let span = max(ActivityDefinition.levelCount - 1, 1)
        return minB + (levelIndex * (maxB - minB)) / span
    }

    init(difficulty: GameDifficulty, levelIndex: Int) {
        self.difficulty = difficulty
        self.levelIndex = levelIndex
        rebuild()
    }

    func start() {
        resolution = nil
        sessionStart = Date()
        elapsed = 0
        currentBeatIndex = 0
        successes = 0
        wrongStreak = 0
        pressPlant = nil
        pressBeganAt = nil
        isPaused = false
        hintFocusedPlant = nil
        hintConsumedThisSession = false
        rebuild()
        beatClosed = Array(repeating: false, count: totalBeats)
        timer?.cancel()
        timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.tick()
        }
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    func clearResolution() {
        resolution = nil
    }

    var playDurationSeconds: Int {
        max(0, Int(Date().timeIntervalSince(sessionStart)))
    }

    private var accuracyValue: Double {
        guard totalBeats > 0 else { return 0 }
        return Double(successes) / Double(totalBeats)
    }

    func beatWindow(for index: Int) -> (start: TimeInterval, end: TimeInterval)? {
        guard index >= 0, index < plantSequence.count else { return nil }
        let start = Double(index) * beatSpacing
        let pulse = pulseDurations[index]
        return (start, start + pulse)
    }

    func setPaused(_ value: Bool) {
        isPaused = value
    }

    func useHint() {
        guard !hintConsumedThisSession, resolution == nil, !isPaused, currentBeatIndex < totalBeats else { return }
        hintConsumedThisSession = true
        hintFocusedPlant = plantSequence[currentBeatIndex]
        HapticFeedback.buttonTap()
    }

    func touchBegan(on plant: Int, at date: Date) {
        guard resolution == nil, !isPaused else { return }
        guard isBeatOpen() else { return }
        let t = date.timeIntervalSince(sessionStart)
        guard let window = beatWindow(for: currentBeatIndex) else { return }
        guard t >= window.start - timingTolerance, t <= window.end + timingTolerance else { return }

        let expected = plantSequence[currentBeatIndex]
        if plant == expected {
            pressPlant = plant
            pressBeganAt = date
            HapticFeedback.majorAction()
        } else {
            closeBeat(success: false)
        }
    }

    func touchEnded(on plant: Int, at date: Date) {
        guard resolution == nil, !isPaused else { return }
        guard let began = pressBeganAt, let pressed = pressPlant, pressed == plant else { return }
        let duration = date.timeIntervalSince(began)
        let t = began.timeIntervalSince(sessionStart)
        guard let window = beatWindow(for: currentBeatIndex) else {
            resetPress()
            return
        }
        let pulse = pulseDurations[currentBeatIndex]
        let minHold: TimeInterval = 0.5
        let maxHold = pulse + timingTolerance * 1.5
        let beganInsideWindow = t >= window.start - timingTolerance && t <= window.end + timingTolerance
        if duration >= minHold, duration <= maxHold, beganInsideWindow {
            successes += 1
            resetPress()
            closeBeat(success: true)
        } else {
            resetPress()
            closeBeat(success: false)
        }
    }

    private func resetPress() {
        pressPlant = nil
        pressBeganAt = nil
    }

    private func isBeatOpen() -> Bool {
        guard currentBeatIndex < totalBeats else { return false }
        guard beatClosed.indices.contains(currentBeatIndex) else { return false }
        return beatClosed[currentBeatIndex] == false
    }

    private func closeBeat(success: Bool) {
        guard resolution == nil else { return }
        guard isBeatOpen() else { return }
        beatClosed[currentBeatIndex] = true
        if success {
            wrongStreak = 0
        } else {
            wrongStreak += 1
        }
        currentBeatIndex += 1
        if hintConsumedThisSession {
            hintFocusedPlant = currentBeatIndex < totalBeats ? plantSequence[currentBeatIndex] : nil
        }
        HapticFeedback.majorAction()
        if wrongStreak >= 3 {
            resolve(success: false)
            return
        }
        if currentBeatIndex >= totalBeats {
            resolve(success: successes == totalBeats)
        }
    }

    private func tick() {
        guard resolution == nil, !isPaused else { return }
        elapsed = Date().timeIntervalSince(sessionStart)
        guard isBeatOpen() else { return }
        guard let window = beatWindow(for: currentBeatIndex) else { return }
        if pressPlant != nil, let began = pressBeganAt {
            let pulse = pulseDurations[currentBeatIndex]
            let maxHold = pulse + timingTolerance * 1.5 + 0.35
            if Date().timeIntervalSince(began) > maxHold {
                resetPress()
                closeBeat(success: false)
            }
            return
        }
        let missDeadline = window.end + timingTolerance + 0.55
        if elapsed > missDeadline {
            closeBeat(success: false)
        }
    }

    private func resolve(success: Bool) {
        guard resolution == nil else { return }
        stop()
        let acc = accuracyValue
        let stars: Int
        if success {
            if acc >= 0.95 {
                stars = 3
            } else if acc >= 0.85 {
                stars = 2
            } else if acc >= 0.7 {
                stars = 1
            } else {
                stars = 0
            }
            var capped = stars
            if hintConsumedThisSession {
                capped = min(capped, 2)
            }
            SystemSounds.playSuccess()
            HapticFeedback.successBanner()
            resolution = Resolution(success: success, stars: capped, accuracy: acc)
            return
        } else {
            stars = 0
            SystemSounds.playFail()
            HapticFeedback.failure()
        }
        resolution = Resolution(success: success, stars: stars, accuracy: acc)
    }

    private func rebuild() {
        plantSequence = (0 ..< totalBeats).map { index in
            [0, 2, 4, 1, 3, 2][index % 6]
        }
        pulseDurations = (0 ..< totalBeats).map { index in
            0.8 + Double((index * 7 + levelIndex * 3) % 5) * 0.08
        }
    }
}
