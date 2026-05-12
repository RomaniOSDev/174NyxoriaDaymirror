//
//  MainTabView.swift
//  174NyxoriaDaymirror
//

import SwiftUI

private enum MainTab: Int, CaseIterable, Identifiable {
    case home
    case play
    case achievements
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .play: return "Play"
        case .achievements: return "Achievements"
        case .settings: return "Settings"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .play: return "leaf.fill"
        case .achievements: return "star.circle.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var selection: MainTab = .home
    @State private var navigationResetID = UUID()

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selection {
                case .home:
                    NavigationStack {
                        HomeView()
                    }
                    .id(navigationResetID)
                case .play:
                    NavigationStack {
                        PlayTabView()
                    }
                    .id(navigationResetID)
                case .achievements:
                    NavigationStack {
                        AchievementsView()
                    }
                    .id(navigationResetID)
                case .settings:
                    NavigationStack {
                        SettingsView()
                    }
                    .id(navigationResetID)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            customTabBar
        }
        .onReceive(NotificationCenter.default.publisher(for: .progressReset)) { _ in
            navigationResetID = UUID()
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases) { tab in
                Button {
                    HapticFeedback.buttonTap()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selection = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 20, weight: .semibold))
                        Text(tab.title)
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(selection == tab ? Color.appBackground : Color.appTextSecondary)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .padding(.vertical, 6)
                    .background {
                        Group {
                            if selection == tab {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppGradients.tabSelectionFill)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(Color.white.opacity(0.16), lineWidth: 0.75)
                                    }
                                    .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
                            }
                        }
                    }
                    .scaleEffect(selection == tab ? 1 : 0.95)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppGradients.chromeTabShell)
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(AppGradients.chromeTabStroke, lineWidth: 1)
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppGradients.topGleam)
            }
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.22), radius: 20, x: 0, y: 12)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 10)
    }
}
