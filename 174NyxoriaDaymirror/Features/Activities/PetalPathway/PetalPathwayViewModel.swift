//
//  PetalPathwayViewModel.swift
//  174NyxoriaDaymirror
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class PetalPathwayViewModel: ObservableObject {
    struct Resolution: Identifiable, Equatable {
        let id = UUID()
        let success: Bool
        let stars: Int
        let elapsed: TimeInterval
    }

    let difficulty: GameDifficulty
    let levelIndex: Int

    @Published private(set) var pathPoints: [CGPoint] = []
    @Published private(set) var flowerStops: [CGFloat] = []
    @Published private(set) var pollinatedCount: Int = 0
    @Published private(set) var creatureProgress: CGFloat = 0
    @Published private(set) var timeRemaining: TimeInterval
    @Published private(set) var resolution: Resolution?

    @Published private(set) var isPaused = false
    @Published private(set) var hintNextBloomIndex: Int?
    private var hintConsumedThisSession = false

    private var timer: AnyCancellable?
    private var sessionStart = Date()
    private var lastValidProgress: CGFloat = 0

    private var pathMarginPoints: CGFloat {
        switch difficulty {
        case .easy: return 28
        case .normal: return 18
        case .hard: return 9
        }
    }

    /// Flower stops scale from early levels to the last (keeps long levels finishable).
    private var flowerCount: Int {
        let minFlowers = 4
        let maxFlowers = 17
        let span = max(ActivityDefinition.levelCount - 1, 1)
        return minFlowers + (levelIndex * (maxFlowers - minFlowers)) / span
    }

    private var timeLimit: TimeInterval {
        let base: TimeInterval
        switch difficulty {
        case .easy: base = 90
        case .normal: base = 60
        case .hard: base = 45
        }
        let extraFlowers = max(0, flowerCount - 4)
        let bonus = min(TimeInterval(extraFlowers) * 1.4, 32)
        return base + bonus
    }

    init(difficulty: GameDifficulty, levelIndex: Int) {
        self.difficulty = difficulty
        self.levelIndex = levelIndex
        timeRemaining = 0
        rebuildLevel()
        timeRemaining = timeLimit
    }

    func start() {
        resolution = nil
        sessionStart = Date()
        timeRemaining = timeLimit
        rebuildLevel()
        isPaused = false
        hintNextBloomIndex = nil
        hintConsumedThisSession = false
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

    func setPaused(_ value: Bool) {
        isPaused = value
    }

    func useHint() {
        guard !hintConsumedThisSession, resolution == nil, !isPaused else { return }
        hintConsumedThisSession = true
        if pollinatedCount < flowerStops.count {
            hintNextBloomIndex = pollinatedCount
        }
        HapticFeedback.buttonTap()
    }

    func drag(to normalizedPoint: CGPoint, in size: CGSize) {
        guard resolution == nil, !isPaused else { return }
        let point = CGPoint(x: normalizedPoint.x * size.width, y: normalizedPoint.y * size.height)
        guard let projection = project(point: point, in: size) else {
            resetToCheckpoint()
            return
        }
        if projection.distance > pathMarginPoints {
            resetToCheckpoint()
            return
        }
        if projection.progress + 0.008 < lastValidProgress {
            resetToCheckpoint()
            return
        }
        creatureProgress = projection.progress
        advancePollinationIfNeeded()
    }

    private func advancePollinationIfNeeded() {
        var advanced = false
        while pollinatedCount < flowerStops.count {
            let target = flowerStops[pollinatedCount]
            if creatureProgress >= target - 0.015 {
                pollinatedCount += 1
                lastValidProgress = max(lastValidProgress, target)
                advanced = true
            } else {
                break
            }
        }
        if advanced {
            HapticFeedback.majorAction()
        }
        if hintConsumedThisSession {
            hintNextBloomIndex = pollinatedCount < flowerStops.count ? pollinatedCount : nil
        }
        if pollinatedCount >= flowerStops.count {
            resolve(success: true)
        }
    }

    private func resetToCheckpoint() {
        creatureProgress = lastValidProgress
        HapticFeedback.buttonTap()
    }

    private func tick() {
        guard resolution == nil, !isPaused else { return }
        timeRemaining -= 0.05
        if timeRemaining <= 0 {
            timeRemaining = 0
            if pollinatedCount < flowerStops.count {
                resolve(success: false)
            }
        }
    }

    private func resolve(success: Bool) {
        guard resolution == nil else { return }
        stop()
        let elapsed = Date().timeIntervalSince(sessionStart)
        let stars: Int
        if success {
            if elapsed <= 30 {
                stars = 3
            } else if elapsed <= 45 {
                stars = 2
            } else if elapsed < 60 {
                stars = 1
            } else {
                stars = 1
            }
            var capped = stars
            if hintConsumedThisSession {
                capped = min(capped, 2)
            }
            HapticFeedback.successBanner()
            SystemSounds.playSuccess()
            resolution = Resolution(success: success, stars: capped, elapsed: elapsed)
            return
        } else {
            stars = 0
            HapticFeedback.failure()
            SystemSounds.playFail()
        }
        resolution = Resolution(success: success, stars: stars, elapsed: elapsed)
    }

    private func rebuildLevel() {
        pathPoints = PetalPathwayGeometry.basePath()
        let flowers = flowerCount
        flowerStops = PetalPathwayGeometry.flowerProgressValues(count: flowers)
        pollinatedCount = 0
        creatureProgress = 0
        lastValidProgress = 0
    }

    func positionAlongPath(progress: CGFloat, in size: CGSize) -> CGPoint {
        let scaled = pathPoints.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
        guard scaled.count >= 2 else { return .zero }
        let clamped = min(max(progress, 0), 1)
        var total: CGFloat = 0
        var lengths: [CGFloat] = []
        for index in 0 ..< scaled.count - 1 {
            let segment = distance(scaled[index], scaled[index + 1])
            lengths.append(segment)
            total += segment
        }
        guard total > 0 else { return scaled[0] }
        var target = clamped * total
        for index in 0 ..< scaled.count - 1 {
            let segment = lengths[index]
            if target <= segment {
                let t = target / max(segment, 0.0001)
                let a = scaled[index]
                let b = scaled[index + 1]
                return CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
            }
            target -= segment
        }
        return scaled.last ?? .zero
    }

    func flowerPositions(in size: CGSize) -> [CGPoint] {
        flowerStops.map { positionAlongPath(progress: $0, in: size) }
    }

    func project(point: CGPoint, in size: CGSize) -> (progress: CGFloat, distance: CGFloat)? {
        guard pathPoints.count >= 2 else { return nil }
        let scaled = pathPoints.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
        var totalLength: CGFloat = 0
        for index in 0 ..< scaled.count - 1 {
            totalLength += distance(scaled[index], scaled[index + 1])
        }
        guard totalLength > 0 else { return nil }

        var bestDistance = CGFloat.greatestFiniteMagnitude
        var bestProgress: CGFloat = 0
        var accumulated: CGFloat = 0

        for index in 0 ..< scaled.count - 1 {
            let a = scaled[index]
            let b = scaled[index + 1]
            let segmentLength = distance(a, b)
            let rawT = projectScalar(point: point, segmentStart: a, segmentEnd: b)
            let clampedT = min(max(rawT, 0), 1)
            let projected = CGPoint(x: a.x + (b.x - a.x) * clampedT, y: a.y + (b.y - a.y) * clampedT)
            let dist = distance(point, projected)
            let progressLength = accumulated + segmentLength * clampedT
            let progress = progressLength / totalLength
            if dist < bestDistance {
                bestDistance = dist
                bestProgress = progress
            }
            accumulated += segmentLength
        }
        return (bestProgress, bestDistance)
    }

    private func projectScalar(point: CGPoint, segmentStart: CGPoint, segmentEnd: CGPoint) -> CGFloat {
        let abx = segmentEnd.x - segmentStart.x
        let aby = segmentEnd.y - segmentStart.y
        let apx = point.x - segmentStart.x
        let apy = point.y - segmentStart.y
        let denom = abx * abx + aby * aby
        if denom == 0 {
            return 0
        }
        return (apx * abx + apy * aby) / denom
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }
}

enum PetalPathwayGeometry {
    static func basePath() -> [CGPoint] {
        [
            CGPoint(x: 0.08, y: 0.86),
            CGPoint(x: 0.18, y: 0.72),
            CGPoint(x: 0.28, y: 0.58),
            CGPoint(x: 0.4, y: 0.5),
            CGPoint(x: 0.52, y: 0.42),
            CGPoint(x: 0.64, y: 0.34),
            CGPoint(x: 0.76, y: 0.26),
            CGPoint(x: 0.86, y: 0.18)
        ]
    }

    static func flowerProgressValues(count: Int) -> [CGFloat] {
        guard count > 0 else { return [] }
        return (1 ... count).map { index in
            CGFloat(index) / CGFloat(count + 1)
        }
    }
}
