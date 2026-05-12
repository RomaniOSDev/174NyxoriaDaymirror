//
//  AppExternalLink.swift
//  174NyxoriaDaymirror
//

import UIKit

enum AppExternalLink: String {
    case privacyPolicy = "https://nyxoriadaymirror174.site/privacy/179"
    case termsOfUse = "https://nyxoriadaymirror174.site/terms/179"

    var url: URL? {
        URL(string: rawValue)
    }

    static func openPrivacyPolicy() {
        if let url = AppExternalLink.privacyPolicy.url {
            UIApplication.shared.open(url)
        }
    }

    static func openTermsOfUse() {
        if let url = AppExternalLink.termsOfUse.url {
            UIApplication.shared.open(url)
        }
    }
}
