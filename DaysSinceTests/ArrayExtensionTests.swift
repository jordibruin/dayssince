@testable import DaysSince
import Foundation
import Testing

/// These tests exercise `Array: RawRepresentable` directly and never touch
/// `UserDefaults` / `Defaults`, so the suite is safe to run in parallel.
@Suite("Array RawRepresentable (JSON string) conformance")
struct ArrayExtensionTests {
    // MARK: - String Array

    @Test("string array round-trips through rawValue")
    func stringArrayRoundTrip() {
        let original = ["hello", "world", "test"]
        let rawValue = original.rawValue
        let decoded = [String](rawValue: rawValue)
        #expect(decoded == original)
    }

    // MARK: - Int Array

    @Test("int array round-trips through rawValue")
    func intArrayRoundTrip() {
        let original = [1, 2, 3, 4, 5]
        let rawValue = original.rawValue
        let decoded = [Int](rawValue: rawValue)
        #expect(decoded == original)
    }

    // MARK: - Empty Array

    @Test("empty array round-trips through rawValue")
    func emptyArrayRoundTrip() {
        let original: [String] = []
        let rawValue = original.rawValue
        let decoded = [String](rawValue: rawValue)
        #expect(decoded == original)
    }

    // MARK: - DSItem Array

    @Test("DSItem array round-trips through rawValue")
    func dsItemArrayRoundTrip() {
        let category = Fixtures.category()
        let items = [
            Fixtures.item(name: "Event 1", category: category, remindersEnabled: true),
            Fixtures.item(name: "Event 2", category: category, remindersEnabled: false),
        ]

        let rawValue = items.rawValue
        let decoded = [DSItem](rawValue: rawValue)

        #expect(decoded != nil)
        #expect(decoded?.count == 2)
        #expect(decoded?[0].name == "Event 1")
        #expect(decoded?[1].name == "Event 2")
    }

    // MARK: - Invalid Data

    @Test("non-JSON raw value decodes to nil")
    func invalidRawValueReturnsNil() {
        let decoded = [String](rawValue: "not valid json")
        #expect(decoded == nil)
    }

    @Test("empty raw value decodes to nil")
    func emptyStringReturnsNil() {
        let decoded = [String](rawValue: "")
        #expect(decoded == nil)
    }

    // MARK: - Raw Value Format

    /// Load-bearing invariant: `@AppStorage`-backed arrays are persisted as JSON
    /// *strings*, not `Data`. Widget code reads them with `.string(forKey:)`.
    @Test("rawValue is a JSON string, not Data")
    func rawValueIsValidJSON() {
        let array = ["a", "b", "c"]
        let rawValue = array.rawValue
        let data = rawValue.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data)
        #expect(json != nil)
    }

    // MARK: - Category Array

    @Test("Category array round-trips through rawValue")
    func categoryArrayRoundTrip() {
        let categories = [
            Fixtures.category(),
            Fixtures.category(
                stableID: DaysSince.Category.stableIDLife,
                name: "Life",
                emoji: "leaf",
                color: .life
            ),
        ]

        let rawValue = categories.rawValue
        let decoded = [DaysSince.Category](rawValue: rawValue)

        #expect(decoded != nil)
        #expect(decoded?.count == 2)
        #expect(decoded?[0].name == "Work")
        #expect(decoded?[1].name == "Life")
    }
}
