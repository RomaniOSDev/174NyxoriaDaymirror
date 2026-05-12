//
//  GameDifficulty.swift
//  174NyxoriaDaymirror
//

import Foundation

enum GameDifficulty: String, CaseIterable, Identifiable {
    case easy
    case normal
    case hard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .hard: return "Hard"
        }
    }

    var storageKey: String { rawValue }
}
