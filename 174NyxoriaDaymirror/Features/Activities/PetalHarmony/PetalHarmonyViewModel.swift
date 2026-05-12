//
//  PetalHarmonyViewModel.swift
//  174NyxoriaDaymirror
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class PetalHarmonyViewModel: ObservableObject {
    struct Ripple: Identifiable, Equatable {
        let id = UUID()
        let position: CGPoint
        let created: Date
    }

    struct Resolution: Identifiable, Equatable {
        let id = UUID()
        let success: Bool
        let stars: Int
        let score: Int
    }

    let difficulty: GameDifficulty
    let levelIndex: Int

    @Published private(set) var score: Int = 0
    @Published private(set) var combo: Int = 0
    @Published private(set) var survivalTime: Double = 0
    @Published private(set) var glowingIndex: Int?
    @Published private(set) var glowExpiresAt: Date?
    @Published private(set) var consecutiveMisses: [Int] = Array(repeating: 0, count: 5)
    @Published private(set) var ripples: [Ripple] = []
    @Published private(set) var sparklePoint: CGPoint?
    @Published private(set) var sparkleExpiresAt: Date?
    @Published private(set) var gardenDim: Double = 0
    @Published private(set) var resolution: Resolution?

    @Published private(set) var isPaused = false
    @Published private(set) var hintPulsePlantIndex: Int?
    private var hintConsumedThisSession = false

    private var timer: AnyCancellable?
    private var sessionStart = Date()
    private var nextSpawnDate = Date()

    private var glowDuration: TimeInterval {
        switch difficulty {
        case .easy: return 3
        case .normal: return 2
        case .hard: return 1
        }
    }

    private var spawnCooldown: TimeInterval {
        let eased = Double(min(levelIndex, 12))
        return max(0.28, 1.06 - eased * 0.055)
    }

    init(difficulty: GameDifficulty, levelIndex: Int) {
        self.difficulty = difficulty
        self.levelIndex = levelIndex
    }

    func start() {
        resolution = nil
        sessionStart = Date()
        survivalTime = 0
        score = 0
        combo = 0
        glowingIndex = nil
        glowExpiresAt = nil
        consecutiveMisses = Array(repeating: 0, count: 5)
        ripples = []
        sparklePoint = nil
        sparkleExpiresAt = nil
        gardenDim = 0
        nextSpawnDate = Date().addingTimeInterval(0.6)
        hintConsumedThisSession = false
        hintPulsePlantIndex = nil
        isPaused = false
        timer?.cancel()
        timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect().sink { [weak self] _ in
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

    func plantPositions() -> [CGPoint] {
        [
            CGPoint(x: 0.2, y: 0.42),
            CGPoint(x: 0.38, y: 0.62),
            CGPoint(x: 0.5, y: 0.36),
            CGPoint(x: 0.62, y: 0.62),
            CGPoint(x: 0.8, y: 0.44)
        ]
    }

    func setPaused(_ value: Bool) {
        isPaused = value
    }

    func useHint() {
        guard !hintConsumedThisSession, resolution == nil, !isPaused else { return }
        hintConsumedThisSession = true
        HapticFeedback.buttonTap()
        if let active = glowingIndex {
            hintPulsePlantIndex = active
        }
    }

    func clearHintPulseIfNeeded(matchingTappedIndex: Int) {
        if hintPulsePlantIndex == matchingTappedIndex {
            hintPulsePlantIndex = nil
        }
    }

    func handleTap(at normalizedPoint: CGPoint, in size: CGSize) {
        guard resolution == nil, !isPaused else { return }
        HapticFeedback.majorAction()
        addRipple(at: normalizedPoint)

        if let sparkle = sparklePoint, let sparkleEnd = sparkleExpiresAt {
            let absolute = CGPoint(x: sparkle.x * size.width, y: sparkle.y * size.height)
            let tap = CGPoint(x: normalizedPoint.x * size.width, y: normalizedPoint.y * size.height)
            let distance = hypot(tap.x - absolute.x, tap.y - absolute.y)
            let now = Date()
            if distance < 54, now < sparkleEnd, let target = glowingIndex, resolvedPlantIndex(forTap: normalizedPoint, in: size, glowingTarget: target) == target {
                score += 24 + combo * 2
                combo += 1
                sparklePoint = nil
                sparkleExpiresAt = nil
            }
        }

        guard let target = glowingIndex, let end = glowExpiresAt else {
            combo = 0
            return
        }

        let tapped = resolvedPlantIndex(forTap: normalizedPoint, in: size, glowingTarget: target)
        let now = Date()

        if tapped == target, now < end {
            consecutiveMisses[tapped] = 0
            clearHintPulseIfNeeded(matchingTappedIndex: tapped)
            score += 12 + combo * 3
            combo += 1
            glowingIndex = nil
            glowExpiresAt = nil
            nextSpawnDate = Date().addingTimeInterval(spawnCooldown * 0.35)
            lightenNeighbors(around: tapped)
        } else if tapped == target {
            combo = 0
        } else {
            combo = max(0, combo - 1)
        }
    }

    private func lightenNeighbors(around index: Int) {
        let neighbors = [index - 1, index + 1].filter { $0 >= 0 && $0 < 5 }
        for neighbor in neighbors {
            consecutiveMisses[neighbor] = max(0, consecutiveMisses[neighbor] - 1)
        }
    }

    private func tick() {
        guard resolution == nil, !isPaused else { return }
        let now = Date()
        survivalTime += 0.05

        if survivalTime >= 60 {
            resolve(success: true)
            return
        }

        if let expires = glowExpiresAt, let index = glowingIndex, now > expires {
            glowingIndex = nil
            glowExpiresAt = nil
            combo = 0
            consecutiveMisses[index] += 1
            HapticFeedback.majorAction()
            if consecutiveMisses[index] >= 3 {
                gardenDim = 1
                resolve(success: false)
            } else {
                nextSpawnDate = Date().addingTimeInterval(spawnCooldown * 0.45)
            }
        }

        ripples.removeAll { now.timeIntervalSince($0.created) > 0.85 }

        if let sparkleEnd = sparkleExpiresAt, now > sparkleEnd {
            sparklePoint = nil
            sparkleExpiresAt = nil
        }

        if glowingIndex == nil, now > nextSpawnDate {
            spawnGlow(at: now)
        }

        maybeSpawnSparkle(now: now)
    }

    private func spawnGlow(at date: Date) {
        let index = Int.random(in: 0 ..< 5)
        glowingIndex = index
        glowExpiresAt = date.addingTimeInterval(glowDuration)
        nextSpawnDate = date.addingTimeInterval(spawnCooldown)
    }

    private func maybeSpawnSparkle(now: Date) {
        guard sparklePoint == nil else { return }
        guard Double.random(in: 0 ... 1) < 0.018 else { return }
        sparklePoint = CGPoint(x: CGFloat.random(in: 0.18 ... 0.82), y: CGFloat.random(in: 0.28 ... 0.78))
        sparkleExpiresAt = now.addingTimeInterval(0.72)
    }

    private func resolve(success: Bool) {
        guard resolution == nil else { return }
        stop()
        let stars: Int
        if success {
            if score >= 150 {
                stars = 3
            } else if score >= 100 {
                stars = 2
            } else if score >= 50 {
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
            resolution = Resolution(success: success, stars: capped, score: score)
            return
        } else {
            stars = 0
            SystemSounds.playFail()
            HapticFeedback.failure()
        }
        resolution = Resolution(success: success, stars: stars, score: score)
    }

    /// While a plant glows, taps inside a generous circle count as that plant (nearest-neighbor alone
    /// often mapped taps to the wrong plant when clusters overlap).
    private func resolvedPlantIndex(forTap normalizedPoint: CGPoint, in size: CGSize, glowingTarget: Int) -> Int {
        let tap = CGPoint(x: normalizedPoint.x * size.width, y: normalizedPoint.y * size.height)
        let points = plantPositions()
        let radius = max(72, min(size.width, size.height) * 0.2)
        let glowingCenter = CGPoint(
            x: points[glowingTarget].x * size.width,
            y: points[glowingTarget].y * size.height
        )
        let distanceToGlowing = hypot(tap.x - glowingCenter.x, tap.y - glowingCenter.y)
        if distanceToGlowing <= radius {
            return glowingTarget
        }
        return nearestPlantIndex(to: normalizedPoint, in: size)
    }

    private func nearestPlantIndex(to normalizedPoint: CGPoint, in size: CGSize) -> Int {
        let points = plantPositions()
        var best = 0
        var bestDistance = CGFloat.greatestFiniteMagnitude
        let tap = CGPoint(x: normalizedPoint.x * size.width, y: normalizedPoint.y * size.height)
        for (index, point) in points.enumerated() {
            let target = CGPoint(x: point.x * size.width, y: point.y * size.height)
            let distance = hypot(tap.x - target.x, tap.y - target.y)
            if distance < bestDistance {
                bestDistance = distance
                best = index
            }
        }
        return best
    }

    private func addRipple(at normalizedPoint: CGPoint) {
        ripples.append(Ripple(position: normalizedPoint, created: Date()))
    }
}
