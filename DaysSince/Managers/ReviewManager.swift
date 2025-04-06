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

    @AppStorage("latestVersionThatReviewWasAskedFor") var latestVersionThatReviewWasAskedFor: String = "1.0"
    
    func promptReviewAlert() {
        guard let currentVersion = UIApplication.appVersion else {
            print("Couldn't get app version")
            return
        }
        
        print("Current version: \(currentVersion), Last asked version: \(latestVersionThatReviewWasAskedFor)")
        
        if currentVersion == latestVersionThatReviewWasAskedFor {
            print("Already asked for this version, do nothing")
            return
        }
        
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            print("Requesting review for version \(currentVersion)")
            SKStoreReviewController.requestReview(in: scene)
            
            Analytics.send(.reviewPrompt)
        }
        
        latestVersionThatReviewWasAskedFor = currentVersion
    }
}
