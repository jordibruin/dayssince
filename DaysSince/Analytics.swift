//
//  Analytics.swift
//  DaysSince
//
//  Created by Victoria Petrova on 06/04/2025.
//

import Foundation
import TelemetryDeck

protocol AnalyticsSending {
    func send(_ option: AnalyticType, with additionalParameters: [String: String]?)
}

struct TelemetryDeckSink: AnalyticsSending {
    func send(_ option: AnalyticType, with additionalParameters: [String: String]?) {
        if let additionalParameters {
            TelemetryDeck.signal(option.rawValue, parameters: additionalParameters)
        } else {
            TelemetryDeck.signal(option.rawValue)
        }
    }
}

/// Drops every signal. Needed because `TelemetryDeck.signal` fatal-errors when the SDK was never
/// initialized, so skipping `TelemetryDeck.initialize` is not on its own enough to go offline.
struct NoOpAnalyticsSink: AnalyticsSending {
    func send(_: AnalyticType, with _: [String: String]?) {}
}

struct Analytics {

    static var sink: AnalyticsSending = TestHooks.networkDisabled
        ? NoOpAnalyticsSink()
        : TelemetryDeckSink()

    static func send(_ option: AnalyticType, with additionalParameters: [String: String]? = nil) {
        sink.send(option, with: additionalParameters)
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

    case iCloudMigrationStarted
    case iCloudMigrationCompleted
    case iCloudSyncConflict
    case iCloudDataSize

    case proSettings
    case proOnboarding
    case proStartPurchase
    case proPurchasedInOnboarding
    case proPurchased
    case exportData

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
        case .iCloudMigrationStarted:
            return "iCloudMigrationStarted"
        case .iCloudMigrationCompleted:
            return "iCloudMigrationCompleted"
        case .iCloudSyncConflict:
            return "iCloudSyncConflict"
        case .iCloudDataSize:
            return "iCloudDataSize"
        case .proSettings:
            return "proSettings"
        case .proOnboarding:
            return "proOnboarding"
        case .proStartPurchase:
            return "proStartPurchase"
        case .proPurchasedInOnboarding:
            return "proPurchasedInOnboarding"
        case .proPurchased:
            return "proPurchased"
        case .exportData:
            return "exportData"
        }
    }
}

public func isSimulatorOrTestFlight() -> Bool {
    guard let path = Bundle.main.appStoreReceiptURL?.path else {
        return false
    }
    return path.contains("CoreSimulator") || path.contains("sandboxReceipt")
}

