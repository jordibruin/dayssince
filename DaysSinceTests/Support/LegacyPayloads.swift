@testable import DaysSince
import Foundation

/// Builds "old data" by encoding a current value and deleting keys that were added
/// after a release. Deriving payloads from the real encoder (rather than hand-writing
/// JSON) keeps the fixtures honest when the models change shape.
enum LegacyPayloads {

    /// JSON for `value` with `keys` removed from the top-level object.
    static func encoded(_ value: some Encodable, without keys: [String]) throws -> Data {
        let data = try JSONEncoder().encode(value)
        var object = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        for key in keys {
            object.removeValue(forKey: key)
        }
        return try JSONSerialization.data(withJSONObject: object)
    }

    /// JSON for an item whose nested `category` object has `keys` removed.
    static func encodedItem(_ item: DSItem, withoutCategoryKeys keys: [String]) throws -> Data {
        let data = try JSONEncoder().encode(item)
        var object = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        var category = object["category"] as! [String: Any]
        for key in keys {
            category.removeValue(forKey: key)
        }
        object["category"] = category
        return try JSONSerialization.data(withJSONObject: object)
    }

    /// A category payload with an arbitrary name and no `stableID`, for exercising the
    /// name → well-known-stableID migration path.
    static func category(named name: String, withoutStableID: Bool = true) throws -> Data {
        let category = Fixtures.category(stableID: "will-be-removed", name: name)
        return try encoded(category, without: withoutStableID ? ["stableID"] : [])
    }
}
