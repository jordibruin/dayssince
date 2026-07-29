@testable import DaysSince
import Foundation

final class SpyWidgetReloader: WidgetReloading {
    private(set) var reloadCount = 0

    func reloadAllTimelines() {
        reloadCount += 1
    }
}

struct StubUbiquityChecker: UbiquityChecking {
    var isUbiquityAvailable: Bool
}
