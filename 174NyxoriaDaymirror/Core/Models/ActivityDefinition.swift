//
//  ActivityDefinition.swift
//  174NyxoriaDaymirror
//

import Foundation

enum ActivityDefinition: String, CaseIterable, Identifiable {
    case petalHarmony
    case petalPathway
    case chorusGrove

    var id: String { rawValue }

    var storageKey: String { rawValue }

    var title: String {
        switch self {
        case .petalHarmony: return "Petal Harmony"
        case .petalPathway: return "Petal Pathway"
        case .chorusGrove: return "Chorus Grove"
        }
    }

    var subtitle: String {
        switch self {
        case .petalHarmony: return "Tap glowing plants and keep the garden thriving."
        case .petalPathway: return "Guide your creature along paths to bloom every flower."
        case .chorusGrove: return "Hold each core in time with the garden’s rhythm."
        }
    }

    /// Levels per activity and difficulty (0-based index … levelCount - 1).
    static let levelCount = 15
}
