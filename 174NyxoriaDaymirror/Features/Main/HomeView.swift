//
//  HomeView.swift
//  174NyxoriaDaymirror
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progressStore: ProgressStore

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5 ..< 12: return "Good morning"
        case 12 ..< 17: return "Good afternoon"
        case 17 ..< 22: return "Good evening"
        default: return "Welcome back"
        }
    }

    private var unlockedAchievementsCount: Int {
        AchievementKind.allCases.filter { $0.isUnlocked(using: progressStore) }.count
    }

    var body: some View {
        ZStack {
            LayeredBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    headerBlock

                    dailyStarsWidget

                    HStack(alignment: .top, spacing: 12) {
                        miniStatWidget(
                            title: "Week stars",
                            value: "\(progressStore.weeklyStarsEarned)",
                            subtitle: "/" + "\(ProgressStore.weeklyStarsChallengeGoal)",
                            icon: "sparkles.rectangle.stack.fill",
                            tint: Color.appAccent
                        )
                        .frame(maxWidth: .infinity)

                        miniStatWidget(
                            title: "Week days",
                            value: "\(progressStore.distinctPlayDaysThisWeek)",
                            subtitle: "/" + "\(ProgressStore.weeklyDistinctDaysGoal)",
                            icon: "calendar",
                            tint: Color.appPrimary
                        )
                        .frame(maxWidth: .infinity)
                    }

                    weekStripWidget

                    achievementsWidget

                    gardenVarietyWidget

                    Text("Play")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)

                    VStack(spacing: 12) {
                        ForEach(ActivityDefinition.allCases) { activity in
                            NavigationLink {
                                ActivitySelectionView(activity: activity)
                            } label: {
                                activityShortcutRow(activity)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .appChromeNavigationBar()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    HowToPlayRootView()
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.appPrimary)
                }
                .accessibilityLabel("How to Play")
            }
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(greeting)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(formattedToday())
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appPrimary.opacity(0.45),
                                    Color.appAccent.opacity(0.32)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.75)
                        }
                        .frame(width: 56, height: 56)
                    Image(systemName: "sun.horizon.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(Color.appBackground)
                }
                .compositingGroup()
                .shadow(color: Color.black.opacity(0.13), radius: 10, x: 0, y: 5)
                .accessibilityHidden(true)
            }

            Text("Garden moments.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedPlate(cornerRadius: 22, elevation: .lifted)
    }

    private var dailyStarsWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Today", systemImage: "star.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .labelStyle(.titleAndIcon)
                    .symbolRenderingMode(.hierarchical)
                    .tint(Color.appAccent)
                Spacer()
                Text("\(progressStore.starsEarnedToday)/\(ProgressStore.dailyStarGoal)")
                    .font(.title3.weight(.bold).monospacedDigit())
                    .foregroundStyle(Color.appAccent)
            }

            ProgressView(
                value: min(Double(progressStore.starsEarnedToday), Double(ProgressStore.dailyStarGoal)),
                total: Double(ProgressStore.dailyStarGoal)
            )
            .progressViewStyle(.linear)
            .labelsHidden()
            .tint(Color.appPrimary)
            .background {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.appBackground.opacity(0.45))
            }
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .frame(height: 10)

            HStack(spacing: 12) {
                Text("\(progressStore.sessionsToday) runs")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                if progressStore.dailyGoalComplete {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Met")
                    }
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color.appAccent)
                }
            }
        }
        .padding(16)
        .appElevatedPlate(cornerRadius: 20, elevation: .lifted)
    }

    private func miniStatWidget(
        title: String,
        value: String,
        subtitle: String,
        icon: String,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(tint)
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
                .textCase(.uppercase)
                .lineLimit(1)
            Text(value + subtitle)
                .font(.title2.weight(.bold).monospacedDigit())
                .foregroundStyle(Color.appTextPrimary)
                .minimumScaleFactor(0.85)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .appElevatedPlate(cornerRadius: 18, elevation: .soft)
    }

    private var weekStripWidget: some View {
        let flags = progressStore.playedOnLastSevenDays()
        let keys = CalendarDay.lastSevenDayKeys()
        return VStack(alignment: .leading, spacing: 8) {
            Text("7 days")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            HStack(spacing: 0) {
                ForEach(Array(keys.enumerated()), id: \.offset) { index, key in
                    VStack(spacing: 6) {
                        Text(weekdayLetter(for: key))
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.appTextSecondary)
                        Circle()
                            .fill(flags[index] ? Color.appPrimary : Color.appSurface.opacity(0.75))
                            .frame(width: 12, height: 12)
                            .overlay {
                                Circle()
                                    .stroke(flags[index] ? Color.appAccent : Color.appTextSecondary.opacity(0.35), lineWidth: 1)
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .appElevatedPlate(cornerRadius: 20, elevation: .soft)
    }

    private var achievementsWidget: some View {
        NavigationLink {
            AchievementsView()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.appAccent.opacity(0.18))
                        .frame(width: 52, height: 52)
                    Image(systemName: "medal.star.fill")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.appAccent)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rewards")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("\(unlockedAchievementsCount)/\(AchievementKind.allCases.count)")
                        .font(.caption.weight(.medium))
                        .monospacedDigit()
                        .foregroundStyle(Color.appTextSecondary)
                    ProgressView(
                        value: Double(unlockedAchievementsCount),
                        total: Double(AchievementKind.allCases.count)
                    )
                    .progressViewStyle(.linear)
                    .labelsHidden()
                    .tint(Color.appAccent)
                    .background {
                        Capsule().fill(Color.appBackground.opacity(0.5))
                    }
                    .clipShape(Capsule())
                    .frame(height: 6)
                    .padding(.top, 2)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.appTextSecondary.opacity(0.8))
                    .font(.body.weight(.semibold))
            }
            .padding(16)
            .appElevatedPlate(cornerRadius: 20, elevation: .lifted)
        }
        .buttonStyle(.plain)
    }

    private var gardenVarietyWidget: some View {
        HStack(spacing: 12) {
            Image(systemName: progressStore.gardenVarietyComplete ? "checkmark.circle.fill" : "leaf.circle")
                .font(.title2.weight(.semibold))
                .foregroundStyle(progressStore.gardenVarietyComplete ? Color.appAccent : Color.appTextSecondary)
            VStack(alignment: .leading, spacing: 2) {
                Text("Variety")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("Every activity • today")
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            if progressStore.gardenVarietyComplete {
                Text("Done")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appPrimary)
            }
        }
        .padding(16)
        .appElevatedPlate(cornerRadius: 18, elevation: .soft)
    }

    private func activityShortcutRow(_ activity: ActivityDefinition) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(iconGradient(for: activity))
                    .frame(width: 56, height: 56)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    }
                Image(systemName: activityIcon(for: activity))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.appBackground.opacity(0.95))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text(activity.subtitle)
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Image(systemName: "arrow.right.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.appPrimary)
        }
        .padding(16)
        .appElevatedPlate(cornerRadius: 18, elevation: .soft)
    }

    private func formattedToday() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    private func weekdayLetter(for dayKey: String) -> String {
        guard let date = CalendarDay.date(fromDayKey: dayKey) else { return "—" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date).uppercased()
    }

    private func activityIcon(for activity: ActivityDefinition) -> String {
        switch activity {
        case .petalHarmony: return "leaf.circle.fill"
        case .petalPathway: return "scribble.variable"
        case .chorusGrove: return "music.note.list"
        }
    }

    private func iconGradient(for activity: ActivityDefinition) -> LinearGradient {
        switch activity {
        case .petalHarmony:
            return LinearGradient(
                colors: [Color.appPrimary.opacity(0.95), Color.appAccent.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .petalPathway:
            return LinearGradient(
                colors: [Color.appAccent.opacity(0.9), Color.appPrimary.opacity(0.65)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .chorusGrove:
            return LinearGradient(
                colors: [Color.appPrimary.opacity(0.75), Color.appAccent.opacity(0.95)],
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject(ProgressStore())
}
