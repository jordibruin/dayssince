@testable import DaysSince
import Foundation

/// In-memory `CategoryStoring` that also counts writes, so a suite can assert a
/// mutation persisted exactly once.
final class MockCategoryStore: CategoryStoring {

    private var stored: [DaysSince.Category]
    private(set) var writeCount = 0

    init(_ categories: [DaysSince.Category] = DaysSince.Category.builtInDefaults) {
        stored = categories
    }

    var categories: [DaysSince.Category] {
        get { stored }
        set {
            stored = newValue
            writeCount += 1
        }
    }
}
