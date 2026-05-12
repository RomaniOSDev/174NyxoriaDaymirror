//
//  PlayTabView.swift
//  174NyxoriaDaymirror
//

import SwiftUI

struct PlayTabView: View {
    var body: some View {
        ZStack {
            LayeredBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Your garden awaits gentle care.")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 14) {
                        ForEach(ActivityDefinition.allCases) { activity in
                            NavigationLink {
                                ActivitySelectionView(activity: activity)
                            } label: {
                                activityCard(activity)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
            }
        }
        .navigationTitle("Play")
        .navigationBarTitleDisplayMode(.inline)
        .appChromeNavigationBar()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    HowToPlayRootView()
                } label: {
                    Image(systemName: "book.fill")
                        .foregroundStyle(Color.appPrimary)
                }
                .accessibilityLabel("How to Play")
            }
        }
    }

    private func activityCard(_ activity: ActivityDefinition) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.38),
                                Color.appAccent.opacity(0.22)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.75)
                    }
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.appBackground.opacity(0.95))
                    .font(.system(size: 24, weight: .semibold))
            }
            .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 6) {
                Text(activity.title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Text(activity.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.appAccent)
                .font(.body.weight(.semibold))
        }
        .padding(16)
        .appElevatedPlate(cornerRadius: 18, elevation: .soft)
    }
}
