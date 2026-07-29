import Foundation

/// A `UserDefaults` suite scoped to a single test, so tests that touch persisted
/// state can run in parallel without bleeding into each other or into `.standard`.
///
/// Call `remove()` (or let `deinit` run) to delete the backing plist — otherwise
/// every test run leaks a file into the test host's container.
final class IsolatedDefaults {
    let suiteName: String
    let defaults: UserDefaults

    init() {
        suiteName = "test.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
    }

    func remove() {
        defaults.removePersistentDomain(forName: suiteName)
    }

    deinit {
        remove()
    }
}
