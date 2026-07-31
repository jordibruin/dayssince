@testable import DaysSince
import Foundation

final class SpyPurchaseNotifier: PurchaseNotifying {
    struct Sent: Equatable {
        let title: String
        let body: String
    }

    private(set) var sent: [Sent] = []

    func send(title: String, body: String) {
        sent.append(Sent(title: title, body: body))
    }
}
