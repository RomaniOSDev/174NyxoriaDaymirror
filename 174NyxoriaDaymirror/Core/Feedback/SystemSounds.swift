//
//  SystemSounds.swift
//  174NyxoriaDaymirror
//

import AudioToolbox

private let systemSoundToggleKey = "progress.soundEffectsEnabled"

enum SystemSounds {
    private static var soundEffectsOn: Bool {
        if UserDefaults.standard.object(forKey: systemSoundToggleKey) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: systemSoundToggleKey)
    }

    static func playSuccess() {
        guard soundEffectsOn else { return }
        AudioServicesPlaySystemSound(1057)
    }

    static func playFail() {
        guard soundEffectsOn else { return }
        AudioServicesPlaySystemSound(1521)
    }
}
