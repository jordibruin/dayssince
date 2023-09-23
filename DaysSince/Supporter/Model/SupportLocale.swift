//
//  SupportLocale.swift
//  Supporter
//
//  Created by Jordi Bruin on 01/12/2021.
//

import Foundation

/// Enum that determines the user's device language so that it can fetch different JSON for different localizations
enum SupportLocale: CaseIterable {
    case english
//    case dutch

    /// Here you can define different urls to use for the different locales you support in your app. Add the langauge to url and languagecode and make sure they match what the system returns in Locale.current.langaugeCode.
    var url: URL {
        switch self {
        case .english:
            return URL(string: "https://simplejsoncms.com/api/59cq27p0jp8")!
//        case .dutch:
//            return URL(string: "https://simplejsoncms.com/api/kpav6tkbns")!
        }
    }

    var languageCode: String {
        switch self {
//        case .dutch:
//            return "nl"
        default:
            return "en"
        }
    }

    init() {
        guard let deviceLanguage = Locale.current.languageCode else {
            print("no languagecode")
            self = .english
            return
        }

        guard let matchingLanguage = SupportLocale.allCases.first(where: { $0.languageCode == deviceLanguage }) else {
            print("no match found")
            self = .english
            return
        }

        print("found a matching langauge \(matchingLanguage)")
        self = matchingLanguage
    }
}
