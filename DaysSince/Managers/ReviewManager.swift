//
//  ReviewManager.swift
//  DaysSince
//
//  Created by Victoria Petrova on 05/04/2025.
//

import Foundation
import StoreKit
import SwiftUI

class ReviewManager: ObservableObject {

    static let lastAskedVersionKey = "latestVersionThatReviewWasAskedFor"

    private let defaults: UserDefaults
    private let appVersion: String?

    /// Returns whether the review sheet was actually presented — StoreKit silently declines
    /// without a foreground-active window scene, and analytics must not claim a prompt happened.
    private let presentReview: () -> Bool

    init(
        defaults: UserDefaults = .standard,
        appVersion: String? = UIApplication.appVersion,
        presentReview: @escaping () -> Bool = ReviewManager.requestReviewInForegroundScene
    ) {
        self.defaults = defaults
        self.appVersion = appVersion
        self.presentReview = presentReview
    }

    var latestVersionThatReviewWasAskedFor: String {
        defaults.string(forKey: Self.lastAskedVersionKey) ?? "1.0"
    }

    /// One prompt per app version, and never for a version we can't read.
    static func shouldPrompt(currentVersion: String?, lastAskedVersion: String) -> Bool {
        guard let currentVersion else { return false }
        return currentVersion != lastAskedVersion
    }

    func promptReviewAlert() {
        guard let currentVersion = appVersion,
              Self.shouldPrompt(
                  currentVersion: currentVersion,
                  lastAskedVersion: latestVersionThatReviewWasAskedFor
              )
        else { return }

        if presentReview() {
            Analytics.send(.reviewPrompt)
        }

        // Recorded even when presentation was declined, so a prompt attempted with no active
        // scene costs the user's single chance for this version.
        defaults.set(currentVersion, forKey: Self.lastAskedVersionKey)
    }

    static func requestReviewInForegroundScene() -> Bool {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return false }

        SKStoreReviewController.requestReview(in: scene)
        return true
    }
}
