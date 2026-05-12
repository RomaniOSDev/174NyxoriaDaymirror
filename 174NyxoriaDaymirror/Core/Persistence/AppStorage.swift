//
//  AppStorage.swift
//  174NyxoriaDaymirror
//

import Combine
import Foundation
import SwiftUI

enum AchievementKind: String, CaseIterable, Identifiable {
    case firstLight
    case newbieGardener
    case timeKeeper
    case starCollector
    case levelUp
    case starMaster
    case activePlayer
    case hundredPlays

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstLight: return "First Light"
        case .newbieGardener: return "Newbie Gardener"
        case .timeKeeper: return "Time Keeper"
        case .starCollector: return "Star Collector"
        case .levelUp: return "Level Up"
        case .starMaster: return "Star Master"
        case .activePlayer: return "Active Player"
        case .hundredPlays: return "Hundred Plays"
        }
    }

    var detail: String {
        switch self {
        case .firstLight: return "Earned your first STAR."
        case .newbieGardener: return "Played 10 activities."
        case .timeKeeper: return "Played for 500 seconds."
        case .starCollector: return "Awarded 50 stars in total."
        case .levelUp: return "Unlocked all available levels."
        case .starMaster: return "Earned 75 stars total."
        case .activePlayer: return "Completed 25 activity sessions."
        case .hundredPlays: return "Completed 100 activity sessions."
        }
    }

    func isUnlocked(using store: ProgressStore) -> Bool {
        switch self {
        case .firstLight:
            return store.totalStarsEarned >= 1
        case .newbieGardener:
            return store.totalActivitiesPlayed >= 10
        case .timeKeeper:
            return store.totalPlayTimeSeconds >= 500
        case .starCollector:
            return store.totalStarsEarned >= 50
        case .levelUp:
            return store.allLevelsUnlocked
        case .starMaster:
            return store.totalStarsEarned >= 75
        case .activePlayer:
            return store.totalActivitiesPlayed >= 25
        case .hundredPlays:
            return store.totalActivitiesPlayed >= 100
        }
    }
}

@MainActor
final class ProgressStore: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "progress.hasSeenOnboarding"
        static let totalActivitiesPlayed = "progress.totalActivitiesPlayed"
        static let totalStarsEarned = "progress.totalStarsEarned"
        static let totalPlayTimeSeconds = "progress.totalPlayTimeSeconds"
        static let starsPerActivity = "progress.starsPerActivity"
        static let unlockedLevels = "progress.unlockedLevels"
        static let streakCount = "progress.streakCount"

        static let soundEffectsEnabled = "progress.soundEffectsEnabled"
        static let comfortableLayout = "progress.comfortableLayout"
        static let prefersLargerInAppText = "progress.prefersLargerInAppText"

        static let lastCalendarDayKey = "progress.lastCalendarDayKey"
        static let starsEarnedToday = "progress.starsEarnedToday"
        static let sessionsToday = "progress.sessionsToday"
        static let playedActivityKeysToday = "progress.playedActivityKeysToday"

        static let isoWeekKeyStored = "progress.isoWeekKeyStored"
        static let weeklyStarsEarned = "progress.weeklyStarsEarned"

        static let playedDateKeys = "progress.playedDateKeys"
    }

    /// Stars to aim for today (motivation card).
    static let dailyStarGoal = 5
    /// Distinct play days in the current week for the weekly challenge.
    static let weeklyDistinctDaysGoal = 4
    /// Weekly STARS target for the seasonal challenge card.
    static let weeklyStarsChallengeGoal = 15

    private let defaults: UserDefaults
    private var resetObserver: NSObjectProtocol?

    @Published var hasSeenOnboarding: Bool
    @Published private(set) var totalActivitiesPlayed: Int
    @Published private(set) var totalStarsEarned: Int
    @Published private(set) var totalPlayTimeSeconds: Int
    @Published private(set) var streakCount: Int
    @Published private(set) var starsPerActivity: [String: [String: [Int]]]
    @Published private(set) var unlockedLevels: [String: [String: Int]]

    @Published var soundEffectsEnabled: Bool
    @Published var comfortableLayoutEnabled: Bool
    @Published var prefersLargerInAppText: Bool

    @Published private(set) var starsEarnedToday: Int
    @Published private(set) var sessionsToday: Int
    @Published private(set) var playedActivityKeysToday: Set<String>

    @Published private(set) var weeklyStarsEarned: Int
    private var isoWeekKeyStored: String

    @Published private(set) var playedDateKeys: Set<String>

    var allLevelsUnlocked: Bool {
        let maxIndex = ActivityDefinition.levelCount - 1
        for activity in ActivityDefinition.allCases {
            for difficulty in GameDifficulty.allCases {
                let value = unlockedLevels[activity.storageKey]?[difficulty.storageKey] ?? 0
                if value < maxIndex {
                    return false
                }
            }
        }
        return true
    }

    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
        hasSeenOnboarding = userDefaults.bool(forKey: Keys.hasSeenOnboarding)
        totalActivitiesPlayed = userDefaults.integer(forKey: Keys.totalActivitiesPlayed)
        totalStarsEarned = userDefaults.integer(forKey: Keys.totalStarsEarned)
        totalPlayTimeSeconds = userDefaults.integer(forKey: Keys.totalPlayTimeSeconds)
        streakCount = userDefaults.integer(forKey: Keys.streakCount)
        starsPerActivity = Self.loadStars(from: userDefaults)
        unlockedLevels = Self.loadUnlocked(from: userDefaults)

        if userDefaults.object(forKey: Keys.soundEffectsEnabled) == nil {
            soundEffectsEnabled = true
        } else {
            soundEffectsEnabled = userDefaults.bool(forKey: Keys.soundEffectsEnabled)
        }
        comfortableLayoutEnabled = userDefaults.bool(forKey: Keys.comfortableLayout)
        prefersLargerInAppText = userDefaults.bool(forKey: Keys.prefersLargerInAppText)

        starsEarnedToday = userDefaults.integer(forKey: Keys.starsEarnedToday)
        sessionsToday = userDefaults.integer(forKey: Keys.sessionsToday)
        playedActivityKeysToday = Self.loadStringSet(from: userDefaults, key: Keys.playedActivityKeysToday)
        weeklyStarsEarned = userDefaults.integer(forKey: Keys.weeklyStarsEarned)
        if let storedWeek = userDefaults.string(forKey: Keys.isoWeekKeyStored) {
            isoWeekKeyStored = storedWeek
        } else {
            isoWeekKeyStored = CalendarDay.isoWeekIdentifier()
            userDefaults.set(isoWeekKeyStored, forKey: Keys.isoWeekKeyStored)
        }
        playedDateKeys = Self.loadStringSet(from: userDefaults, key: Keys.playedDateKeys)

        Self.syncSoundEffectsUserDefaults(soundEffectsEnabled)

        rolloverDailyIfNeeded()
        rolloverWeeklyIfNeeded()

        resetObserver = NotificationCenter.default.addObserver(forName: .progressReset, object: nil, queue: .main) { [weak self] _ in
            self?.reloadFromDefaultsAfterExternalReset()
        }
    }

    deinit {
        if let resetObserver {
            NotificationCenter.default.removeObserver(resetObserver)
        }
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
        defaults.set(true, forKey: Keys.hasSeenOnboarding)
    }

    func setSoundEffectsEnabled(_ value: Bool) {
        soundEffectsEnabled = value
        defaults.set(value, forKey: Keys.soundEffectsEnabled)
        Self.syncSoundEffectsUserDefaults(value)
    }

    func setComfortableLayoutEnabled(_ value: Bool) {
        comfortableLayoutEnabled = value
        defaults.set(value, forKey: Keys.comfortableLayout)
        objectWillChange.send()
    }

    func setPrefersLargerInAppText(_ value: Bool) {
        prefersLargerInAppText = value
        defaults.set(value, forKey: Keys.prefersLargerInAppText)
        objectWillChange.send()
    }

    var dailyStarGoalProgress: Double {
        min(Double(starsEarnedToday) / Double(Self.dailyStarGoal), 1)
    }

    var dailyGoalComplete: Bool {
        starsEarnedToday >= Self.dailyStarGoal
    }

    var distinctPlayDaysThisWeek: Int {
        CalendarDay.playDatesInCurrentWeek(from: playedDateKeys).count
    }

    var weekBloomChallengeComplete: Bool {
        distinctPlayDaysThisWeek >= Self.weeklyDistinctDaysGoal
    }

    var weeklyStarRainComplete: Bool {
        weeklyStarsEarned >= Self.weeklyStarsChallengeGoal
    }

    var gardenVarietyComplete: Bool {
        playedActivityKeysToday.count >= ActivityDefinition.allCases.count
    }

    var weeklyStarChallengeProgress: Double {
        min(Double(weeklyStarsEarned) / Double(Self.weeklyStarsChallengeGoal), 1)
    }

    func playedOnLastSevenDays() -> [Bool] {
        let keys = CalendarDay.lastSevenDayKeys()
        return keys.map { playedDateKeys.contains($0) }
    }

    func dynamicTypeSizeOverride() -> DynamicTypeSize {
        prefersLargerInAppText ? .xxxLarge : .large
    }

    private func rolloverDailyIfNeeded() {
        let today = CalendarDay.dayKey()
        let storedDay = defaults.string(forKey: Keys.lastCalendarDayKey)
        if storedDay == today {
            starsEarnedToday = defaults.integer(forKey: Keys.starsEarnedToday)
            sessionsToday = defaults.integer(forKey: Keys.sessionsToday)
            playedActivityKeysToday = Self.loadStringSet(from: defaults, key: Keys.playedActivityKeysToday)
            return
        }
        if storedDay != nil {
            starsEarnedToday = 0
            sessionsToday = 0
            playedActivityKeysToday = []
            defaults.set(0, forKey: Keys.starsEarnedToday)
            defaults.set(0, forKey: Keys.sessionsToday)
            Self.saveStringSet([], to: defaults, key: Keys.playedActivityKeysToday)
        }
        defaults.set(today, forKey: Keys.lastCalendarDayKey)
        if storedDay == nil {
            starsEarnedToday = defaults.integer(forKey: Keys.starsEarnedToday)
            sessionsToday = defaults.integer(forKey: Keys.sessionsToday)
            playedActivityKeysToday = Self.loadStringSet(from: defaults, key: Keys.playedActivityKeysToday)
        }
    }

    private func rolloverWeeklyIfNeeded() {
        let current = CalendarDay.isoWeekIdentifier()
        if isoWeekKeyStored != current {
            weeklyStarsEarned = 0
            isoWeekKeyStored = current
            defaults.set(0, forKey: Keys.weeklyStarsEarned)
            defaults.set(current, forKey: Keys.isoWeekKeyStored)
        }
    }

    private func pruneOldPlayedDates() {
        let recent = Set(CalendarDay.lastSevenDayKeys())
        playedDateKeys = playedDateKeys.intersection(recent.union([CalendarDay.dayKey()]))
        Self.saveStringSet(playedDateKeys, to: defaults, key: Keys.playedDateKeys)
    }

    static func syncSoundEffectsUserDefaults(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Keys.soundEffectsEnabled)
    }

    nonisolated static func loadStringSet(from defaults: UserDefaults, key: String) -> Set<String> {
        guard let data = defaults.data(forKey: key),
              let arr = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(arr)
    }

    private static func saveStringSet(_ value: Set<String>, to defaults: UserDefaults, key: String) {
        let arr = Array(value).sorted()
        if let data = try? JSONEncoder().encode(arr) {
            defaults.set(data, forKey: key)
        }
    }

    func stars(activity: ActivityDefinition, difficulty: GameDifficulty, level: Int) -> Int {
        guard level >= 0, level < ActivityDefinition.levelCount else { return 0 }
        let row = starsPerActivity[activity.storageKey]?[difficulty.storageKey]
        if let row, level < row.count {
            return row[level]
        }
        return 0
    }

    func highestUnlockedLevelIndex(activity: ActivityDefinition, difficulty: GameDifficulty) -> Int {
        unlockedLevels[activity.storageKey]?[difficulty.storageKey] ?? 0
    }

    func isLevelUnlocked(activity: ActivityDefinition, difficulty: GameDifficulty, levelIndex: Int) -> Bool {
        levelIndex <= highestUnlockedLevelIndex(activity: activity, difficulty: difficulty)
    }

    func recordSessionOutcome(
        activity: ActivityDefinition,
        difficulty: GameDifficulty,
        levelIndex: Int,
        starsEarned: Int,
        playSeconds: Int,
        isPractice: Bool = false
    ) {
        rolloverDailyIfNeeded()
        rolloverWeeklyIfNeeded()

        if isPractice {
            return
        }

        let clampedStars = min(max(starsEarned, 0), 3)
        let clampedSeconds = max(playSeconds, 0)

        let today = CalendarDay.dayKey()
        starsEarnedToday += clampedStars
        sessionsToday += 1
        var playedToday = playedActivityKeysToday
        playedToday.insert(activity.storageKey)
        playedActivityKeysToday = playedToday
        defaults.set(starsEarnedToday, forKey: Keys.starsEarnedToday)
        defaults.set(sessionsToday, forKey: Keys.sessionsToday)
        Self.saveStringSet(playedActivityKeysToday, to: defaults, key: Keys.playedActivityKeysToday)

        playedDateKeys.insert(today)
        pruneOldPlayedDates()

        weeklyStarsEarned += clampedStars
        defaults.set(weeklyStarsEarned, forKey: Keys.weeklyStarsEarned)

        totalActivitiesPlayed += 1
        totalStarsEarned += clampedStars
        totalPlayTimeSeconds += clampedSeconds

        defaults.set(totalActivitiesPlayed, forKey: Keys.totalActivitiesPlayed)
        defaults.set(totalStarsEarned, forKey: Keys.totalStarsEarned)
        defaults.set(totalPlayTimeSeconds, forKey: Keys.totalPlayTimeSeconds)

        if clampedStars > 0 {
            var activityMap = starsPerActivity[activity.storageKey] ?? [:]
            var row = activityMap[difficulty.storageKey] ?? Array(repeating: 0, count: ActivityDefinition.levelCount)
            if levelIndex >= 0, levelIndex < row.count {
                row[levelIndex] = max(row[levelIndex], clampedStars)
            }
            activityMap[difficulty.storageKey] = row
            starsPerActivity[activity.storageKey] = activityMap
            Self.saveStars(starsPerActivity, to: defaults)
        }

        if clampedStars >= 1 {
            streakCount += 1
            var activityUnlock = unlockedLevels[activity.storageKey] ?? [:]
            let current = activityUnlock[difficulty.storageKey] ?? 0
            let nextCap = ActivityDefinition.levelCount - 1
            let proposed = max(current, min(levelIndex + 1, nextCap))
            activityUnlock[difficulty.storageKey] = proposed
            unlockedLevels[activity.storageKey] = activityUnlock
            Self.saveUnlocked(unlockedLevels, to: defaults)
        } else {
            streakCount = 0
        }
        defaults.set(streakCount, forKey: Keys.streakCount)

        objectWillChange.send()
    }

    func resetAllProgressToDefaults() {
        let keys = [
            Keys.hasSeenOnboarding,
            Keys.totalActivitiesPlayed,
            Keys.totalStarsEarned,
            Keys.totalPlayTimeSeconds,
            Keys.starsPerActivity,
            Keys.unlockedLevels,
            Keys.streakCount,
            Keys.soundEffectsEnabled,
            Keys.comfortableLayout,
            Keys.prefersLargerInAppText,
            Keys.lastCalendarDayKey,
            Keys.starsEarnedToday,
            Keys.sessionsToday,
            Keys.playedActivityKeysToday,
            Keys.isoWeekKeyStored,
            Keys.weeklyStarsEarned,
            Keys.playedDateKeys
        ]
        keys.forEach { defaults.removeObject(forKey: $0) }
        defaults.synchronize()
        reloadFromDefaultsAfterExternalReset()
        NotificationCenter.default.post(name: .progressReset, object: nil)
    }

    private func reloadFromDefaultsAfterExternalReset() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalActivitiesPlayed = defaults.integer(forKey: Keys.totalActivitiesPlayed)
        totalStarsEarned = defaults.integer(forKey: Keys.totalStarsEarned)
        totalPlayTimeSeconds = defaults.integer(forKey: Keys.totalPlayTimeSeconds)
        streakCount = defaults.integer(forKey: Keys.streakCount)
        starsPerActivity = Self.loadStars(from: defaults)
        unlockedLevels = Self.loadUnlocked(from: defaults)

        if defaults.object(forKey: Keys.soundEffectsEnabled) == nil {
            soundEffectsEnabled = true
        } else {
            soundEffectsEnabled = defaults.bool(forKey: Keys.soundEffectsEnabled)
        }
        comfortableLayoutEnabled = defaults.bool(forKey: Keys.comfortableLayout)
        prefersLargerInAppText = defaults.bool(forKey: Keys.prefersLargerInAppText)
        starsEarnedToday = defaults.integer(forKey: Keys.starsEarnedToday)
        sessionsToday = defaults.integer(forKey: Keys.sessionsToday)
        playedActivityKeysToday = Self.loadStringSet(from: defaults, key: Keys.playedActivityKeysToday)
        weeklyStarsEarned = defaults.integer(forKey: Keys.weeklyStarsEarned)
        if let w = defaults.string(forKey: Keys.isoWeekKeyStored) {
            isoWeekKeyStored = w
        } else {
            isoWeekKeyStored = CalendarDay.isoWeekIdentifier()
        }
        playedDateKeys = Self.loadStringSet(from: defaults, key: Keys.playedDateKeys)
        Self.syncSoundEffectsUserDefaults(soundEffectsEnabled)
        rolloverDailyIfNeeded()
        rolloverWeeklyIfNeeded()
        objectWillChange.send()
    }

    private static func emptyStars() -> [String: [String: [Int]]] {
        var map: [String: [String: [Int]]] = [:]
        for activity in ActivityDefinition.allCases {
            var inner: [String: [Int]] = [:]
            for difficulty in GameDifficulty.allCases {
                inner[difficulty.storageKey] = Array(repeating: 0, count: ActivityDefinition.levelCount)
            }
            map[activity.storageKey] = inner
        }
        return map
    }

    private static func emptyUnlocked() -> [String: [String: Int]] {
        var map: [String: [String: Int]] = [:]
        for activity in ActivityDefinition.allCases {
            var inner: [String: Int] = [:]
            for difficulty in GameDifficulty.allCases {
                inner[difficulty.storageKey] = 0
            }
            map[activity.storageKey] = inner
        }
        return map
    }

    private static func loadStars(from defaults: UserDefaults) -> [String: [String: [Int]]] {
        guard let data = defaults.data(forKey: Keys.starsPerActivity) else {
            return emptyStars()
        }
        if let decoded = try? JSONDecoder().decode([String: [String: [Int]]].self, from: data) {
            return mergeStarsBaseline(decoded)
        }
        return emptyStars()
    }

    private static func mergeStarsBaseline(_ value: [String: [String: [Int]]]) -> [String: [String: [Int]]] {
        var base = emptyStars()
        for activity in ActivityDefinition.allCases {
            guard let inner = value[activity.storageKey] else { continue }
            for difficulty in GameDifficulty.allCases {
                let incoming = inner[difficulty.storageKey] ?? []
                var row = base[activity.storageKey]?[difficulty.storageKey] ?? Array(repeating: 0, count: ActivityDefinition.levelCount)
                for index in 0 ..< row.count {
                    if index < incoming.count {
                        row[index] = min(max(incoming[index], 0), 3)
                    }
                }
                base[activity.storageKey]?[difficulty.storageKey] = row
            }
        }
        return base
    }

    private static func saveStars(_ value: [String: [String: [Int]]], to defaults: UserDefaults) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: Keys.starsPerActivity)
        }
    }

    private static func loadUnlocked(from defaults: UserDefaults) -> [String: [String: Int]] {
        guard let data = defaults.data(forKey: Keys.unlockedLevels) else {
            return emptyUnlocked()
        }
        if let decoded = try? JSONDecoder().decode([String: [String: Int]].self, from: data) {
            return mergeUnlockedBaseline(decoded)
        }
        return emptyUnlocked()
    }

    private static func mergeUnlockedBaseline(_ value: [String: [String: Int]]) -> [String: [String: Int]] {
        var base = emptyUnlocked()
        for activity in ActivityDefinition.allCases {
            guard let inner = value[activity.storageKey] else { continue }
            for difficulty in GameDifficulty.allCases {
                if let v = inner[difficulty.storageKey] {
                    let capped = min(max(v, 0), ActivityDefinition.levelCount - 1)
                    base[activity.storageKey]?[difficulty.storageKey] = capped
                }
            }
        }
        return base
    }

    private static func saveUnlocked(_ value: [String: [String: Int]], to defaults: UserDefaults) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: Keys.unlockedLevels)
        }
    }
}
