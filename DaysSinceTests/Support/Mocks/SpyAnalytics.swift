@testable import DaysSince
import Foundation

final class SpyAnalytics: AnalyticsSending {

    struct Call: Equatable {
        let type: AnalyticType
        let parameters: [String: String]?
    }

    private let lock = NSLock()
    private var recorded: [Call] = []

    var calls: [Call] {
        lock.lock()
        defer { lock.unlock() }
        return recorded
    }

    var types: [AnalyticType] { calls.map(\.type) }

    func send(_ option: AnalyticType, with additionalParameters: [String: String]?) {
        lock.lock()
        recorded.append(Call(type: option, parameters: additionalParameters))
        lock.unlock()
    }

    func count(of type: AnalyticType) -> Int {
        types.filter { $0 == type }.count
    }

    func parameters(of type: AnalyticType) -> [String: String]? {
        calls.first { $0.type == type }?.parameters
    }
}

/// Installs a `SpyAnalytics` as the global `Analytics.sink` for the duration of `body`
/// and restores the previous sink afterwards. `Analytics.sink` is process-global, so
/// callers must live inside `GlobalStateSuite`.
func withAnalyticsSpy<T>(_ body: (SpyAnalytics) throws -> T) rethrows -> T {
    let previous = Analytics.sink
    let spy = SpyAnalytics()
    Analytics.sink = spy
    defer { Analytics.sink = previous }
    return try body(spy)
}
