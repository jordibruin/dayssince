//
//  Analytics.swift
//  DaysSince
//
//  Created by Victoria Petrova on 06/04/2025.
//

import Foundation
import TelemetryDeck

struct Analytics {
    
    static func send(_ option: AnalyticType, with additionalParameters: [String: String]? = nil) {
        
        if let additionalParameters {
            TelemetryDeck.signal(option.rawValue, parameters: additionalParameters)
        } else {
            TelemetryDeck.signal(option.rawValue)
        }
//        debugPrint("📊 \(option.rawValue) \(additionalParameters?["recipeID"] ?? "")")
//        debugPrint(📊 \(option.rawValue) \(additionalParameters))
    }
    
}

enum AnalyticType: String, Hashable {
     
    case launchApp
    case addNewEvent
    case editEvent
    
    case updateCategory
    case addNewCategory
    
    case chooseIcon
    case chooseTheme
    
    case settingsReview
    case reviewPrompt
    case detailedModeOn
    
    //    case proTheme
    //    case proIcons
    //    case proSettings
    //    case proHome
    //    case proOnboarding
    //    case proStartPurchase
    //    case proPurchasedInOnboarding
    //    case proPurchased
    
    func stringValue() -> String {
        switch self {
        case .launchApp:
            return "launchApp"
        case .editEvent:
            return "editEvent"
        case .updateCategory:
            return "updateCategory"
        case .addNewCategory:
            return "addNewCategory"
        case .chooseIcon:
            return "chooseIcon"
        case .addNewEvent:
            return "addNewEvent"
        case .chooseTheme:
            return "chooseTheme"
        case .reviewPrompt:
            return "reviewPrompt"
        case .settingsReview:
            return "settingsReview"
        case .detailedModeOn:
            return "detailedModeOn"
        }
    }
}

public func isSimulatorOrTestFlight() -> Bool {
    guard let path = Bundle.main.appStoreReceiptURL?.path else {
        return false
    }
    return path.contains("CoreSimulator") || path.contains("sandboxReceipt")
}

