//
//  PurchaseNotifying.swift
//  DaysSince
//

import Foundation

/// Out-of-band notification of a sale, so tests never POST to the live ntfy topic.
protocol PurchaseNotifying {
    func send(title: String, body: String)
}

struct NtfyNotifier: PurchaseNotifying {
    static let topic = "https://ntfy.sh/dayssince-kahwn82"

    func send(title: String, body: String) {
        guard let url = URL(string: Self.topic) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        request.setValue(title, forHTTPHeaderField: "Title")
        request.setValue("DaysSince", forHTTPHeaderField: "Tags")
        URLSession.shared.dataTask(with: request).resume()
    }
}
