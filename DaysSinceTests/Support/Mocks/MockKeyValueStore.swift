@testable import DaysSince
import Foundation

/// In-memory stand-in for `NSUbiquitousKeyValueStore`.
final class MockKeyValueStore: KeyValueStoreProtocol {
    var storage: [String: Any] = [:]
    private(set) var synchronizeCount = 0

    init(storage: [String: Any] = [:]) {
        self.storage = storage
    }

    func data(forKey key: String) -> Data? {
        storage[key] as? Data
    }

    func set(_ value: Any?, forKey key: String) {
        storage[key] = value
    }

    func synchronize() -> Bool {
        synchronizeCount += 1
        return true
    }

    // MARK: - Convenience

    /// `try!` deliberately: the only way this throws is if a model stops being encodable, which
    /// is a programming error every caller shares, and a trap here names it immediately. Making it
    /// throwing would push `try` through 20 harness call sites to no benefit.
    func encode(_ value: some Encodable, forKey key: String) {
        storage[key] = try! JSONEncoder().encode(value)
    }

    func decode<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
