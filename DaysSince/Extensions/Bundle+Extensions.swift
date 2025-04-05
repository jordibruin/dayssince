//
//  Bundle+Extensions.swift
//  DaysSince
//
//  Created by Victoria Petrova on 05/04/2025.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
