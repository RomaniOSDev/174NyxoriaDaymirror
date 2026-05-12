//
//  HowToPlayViews.swift
//  174NyxoriaDaymirror
//

import SwiftUI

struct HowToPlayRootView: View {
    var body: some View {
        ZStack {
            LayeredBackgroundView()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Learn how each path works. Nothing is timed until you start a level.")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(ActivityDefinition.allCases) { activity in
                        NavigationLink {
                            HowToPlayDetailView(activity: activity)
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "leaf.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.appPrimary)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(activity.title)
                                        .font(.headline)
                                        .foregroundStyle(Color.appTextPrimary)
                                    Text("How it works")
                                        .font(.caption)
                                        .foregroundStyle(Color.appTextSecondary)
                                }
                                Spacer(minLength: 0)
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color.appAccent)
                            }
                            .padding(16)
                            .appElevatedPlate(cornerRadius: 16, elevation: .soft)
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer(minLength: 40)
                }
                .padding(18)
            }
        }
        .navigationTitle("How to Play")
        .navigationBarTitleDisplayMode(.inline)
        .appChromeNavigationBar()
    }
}

struct HowToPlayDetailView: View {
    let activity: ActivityDefinition

    var body: some View {
        ZStack {
            LayeredBackgroundView()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(bodyText)
                        .font(.body)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    tipsBlock

                    Spacer(minLength: 48)
                }
                .padding(20)
            }
        }
        .navigationTitle(titleText)
        .navigationBarTitleDisplayMode(.inline)
        .appChromeNavigationBar()
    }

    private var titleText: String {
        switch activity {
        case .petalHarmony: return "Petal Harmony"
        case .petalPathway: return "Petal Pathway"
        case .chorusGrove: return "Chorus Grove"
        }
    }

    private var bodyText: String {
        switch activity {
        case .petalHarmony:
            return "Plants glow one at a time. Tap the glowing plant before the light fades. Keep every plant from missing three glows in a row. Survive the full round and raise your score with combos. Golden sparkles grant a burst of points when tapped in time."
        case .petalPathway:
            return "Drag along the painted lane without leaving it. Bloom every flower in order before the timer ends. If you slip off the path, you return to your last bloomed flower — stay smooth and steady."
        case .chorusGrove:
            return "Each beat highlights one core. Press and hold the highlighted plant so your press begins inside the pulse window, keep contact for at least half a second, and release before the pulse ends. Finish every beat in the loop without three mistakes in a row."
        }
    }

    private var tipsBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tips")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Group {
                switch activity {
                case .petalHarmony:
                    Text("Tap near the heart of the plant while it glows. Use Pause anytime.")
                    Text("One hint per attempt: it marks the active plant; your best score is capped at two STARS when a hint is used.")
                case .petalPathway:
                    Text("Higher difficulties narrow the path and shorten the timer. Extra flowers appear on later levels.")
                    Text("Each stage allows one hint run: your best result is capped at two STARS for that attempt.")
                case .chorusGrove:
                    Text("Listen for the rhythm: pulses arrive about one second apart. If you start late, you can still succeed if your hold length fits the pulse.")
                    Text("Hints outline the next core; using a hint caps your stars at two for that attempt.")
                }
            }
            .font(.subheadline)
            .foregroundStyle(Color.appTextSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedPlate(cornerRadius: 16, elevation: .soft)
    }
}
