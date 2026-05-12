//
//  ContentView.swift
//  174NyxoriaDaymirror
//

import SwiftUI

struct ContentView: View {
    @StateObject private var progressStore = ProgressStore()

    var body: some View {
        Group {
            if progressStore.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(progressStore)
        .environment(\.dynamicTypeSize, progressStore.dynamicTypeSizeOverride())
    }
}

#Preview {
    ContentView()
}
