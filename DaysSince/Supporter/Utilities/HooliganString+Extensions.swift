//
//  String+Extensions.swift
//  Supporter
//
//  Created by Jordi Bruin on 05/12/2021.
//

import Foundation

// Rendering markdown is only supported on iOS 15

/// For rendering markdown in JSON input
extension String {
    @available(iOS 15, *)
    func toMarkdown() -> AttributedString {
        do {
            return try AttributedString(markdown: self)
        } catch {
            print("Error parsing Markdown for string \(self): \(error)")
            return AttributedString(self)
        }
    }
}
