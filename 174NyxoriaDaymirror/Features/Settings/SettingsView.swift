//
//  SettingsView.swift
//  174NyxoriaDaymirror
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var showResetConfirm = false

    private var versionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return version ?? "1.0"
    }

    var body: some View {
        ZStack {
            LayeredBackgroundView()
            ScrollView {
                VStack(spacing: 16) {
                    statsCard

                    soundSection
                    accessibilitySection

                    NavigationLink {
                        HowToPlayRootView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "book.fill")
                                .foregroundStyle(Color.appAccent)
                                .frame(width: 28, alignment: .center)
                            Text("How to Play")
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(minHeight: 44)
                        .appElevatedPlate(cornerRadius: 16, elevation: .muted)
                    }

                    settingsRow(title: "Rate Us", systemImage: "star.fill") {
                        HapticFeedback.buttonTap()
                        rateApp()
                    }
                    settingsRow(title: "Privacy Policy", systemImage: "hand.raised.fill") {
                        HapticFeedback.buttonTap()
                        AppExternalLink.openPrivacyPolicy()
                    }
                    settingsRow(title: "Terms of Use", systemImage: "doc.text.fill") {
                        HapticFeedback.buttonTap()
                        AppExternalLink.openTermsOfUse()
                    }
                    settingsRow(title: "Support", systemImage: "envelope.fill") {
                        HapticFeedback.buttonTap()
                        openSupportEmail()
                    }
                    Button {
                        HapticFeedback.buttonTap()
                        showResetConfirm = true
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Reset All Progress")
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Spacer()
                        }
                        .foregroundStyle(Color.red.opacity(0.95))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(minHeight: 44)
                        .appElevatedPlate(cornerRadius: 16, elevation: .muted, mutedRim: true)
                    }
                    .buttonStyle(.plain)

                    Text("Version \(versionText)")
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)

                    Spacer(minLength: 120)
                }
                .padding(18)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .appChromeNavigationBar()
        .alert("Reset All Progress?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {
                HapticFeedback.buttonTap()
            }
            Button("Reset", role: .destructive) {
                HapticFeedback.majorAction()
                progressStore.resetAllProgressToDefaults()
            }
        } message: {
            Text("This removes saved progress, stars, and unlocked levels on this device.")
        }
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            statRow(title: "Activities Played", value: "\(progressStore.totalActivitiesPlayed)")
            statRow(title: "STARS Earned", value: "\(progressStore.totalStarsEarned)")
            statRow(title: "Time in Activities", value: formattedTime(progressStore.totalPlayTimeSeconds))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedPlate(cornerRadius: 18, elevation: .soft)
    }

    private var soundSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Audio")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Toggle(isOn: Binding(
                get: { progressStore.soundEffectsEnabled },
                set: { progressStore.setSoundEffectsEnabled($0) }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Short sounds")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Uses only brief system sounds — never the microphone.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .tint(Color.appPrimary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedPlate(cornerRadius: 18, elevation: .soft)
    }

    private var accessibilitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Comfort & reading")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            Toggle(isOn: Binding(
                get: { progressStore.comfortableLayoutEnabled },
                set: { progressStore.setComfortableLayoutEnabled($0) }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Roomier level grid")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Larger tiles when picking a stage.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .tint(Color.appPrimary)

            Toggle(isOn: Binding(
                get: { progressStore.prefersLargerInAppText },
                set: { progressStore.setPrefersLargerInAppText($0) }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Larger in-app text")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Applies across tabs for easier reading.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .tint(Color.appPrimary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedPlate(cornerRadius: 18, elevation: .soft)
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(Color.appTextPrimary)
                .font(.body.weight(.semibold))
        }
    }

    private func formattedTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    private func settingsRow(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundStyle(Color.appAccent)
                    .frame(width: 28, alignment: .center)
                Text(title)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .appElevatedPlate(cornerRadius: 16, elevation: .muted)
        }
        .buttonStyle(.plain)
    }

    private func openSupportEmail() {
        let address = "support@example.com"
        let urlString = "mailto:\(address)"
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
