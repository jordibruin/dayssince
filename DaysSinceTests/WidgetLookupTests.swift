@testable import DaysSince
import Foundation
import Testing

/// Pure tier. Covers what the widget timeline providers do with an intent configuration:
/// resolve slot identifiers against the App Group item list. `WidgetContent` itself is only
/// compiled into the widget target, so the provider-side mapping is exercised through
/// `DSItem.daysAgo` instead (see `DSItemTests`).
@Suite("Widget lookup")
struct WidgetLookupTests {

    private let items = [
        Fixtures.item(name: "Dentist"),
        Fixtures.item(name: "Gym"),
        Fixtures.item(name: "Haircut"),
    ]

    // MARK: - Single event

    @Test("a slot resolves by the item's uuidString")
    func resolvesByUUIDString() throws {
        let target = items[1]

        let found = try #require(DSItem.first(matching: target.id.uuidString, in: items))

        #expect(found.id == target.id)
        #expect(found.name == "Gym")
    }

    @Test("an unconfigured slot resolves to nothing", arguments: [nil, ""] as [String?])
    func unconfiguredSlot(id: String?) {
        #expect(DSItem.first(matching: id, in: items) == nil)
    }

    @Test("a slot pointing at a deleted event resolves to nothing")
    func deletedEvent() {
        #expect(DSItem.first(matching: UUID().uuidString, in: items) == nil)
    }

    @Test("lookup is exact, not prefix or case insensitive")
    func lookupIsExact() throws {
        let id = items[0].id.uuidString

        #expect(DSItem.first(matching: String(id.dropLast()), in: items) == nil)
        #expect(DSItem.first(matching: id.lowercased(), in: items) == nil)
    }

    @Test("an empty item list resolves to nothing")
    func emptyItemList() {
        #expect(DSItem.first(matching: UUID().uuidString, in: []) == nil)
    }

    // MARK: - Multiple events

    @Test("slots keep their configured order, not the stored order")
    func slotsKeepConfiguredOrder() {
        let ids = [items[2].id.uuidString, items[0].id.uuidString]

        let resolved = DSItem.matching(ids: ids, in: items)

        #expect(resolved.map(\.name) == ["Haircut", "Dentist"])
    }

    @Test("unset and deleted slots collapse without shifting the rest")
    func missingSlotsAreSkipped() {
        let ids = [nil, items[0].id.uuidString, UUID().uuidString, "", items[1].id.uuidString]

        let resolved = DSItem.matching(ids: ids, in: items)

        #expect(resolved.map(\.name) == ["Dentist", "Gym"])
    }

    @Test("no more than five events are returned")
    func capsAtFive() {
        let many = (0 ..< 8).map { Fixtures.item(name: "Event \($0)") }

        let resolved = DSItem.matching(ids: many.map(\.id.uuidString), in: many)

        #expect(resolved.count == 5)
        #expect(resolved.map(\.name) == ["Event 0", "Event 1", "Event 2", "Event 3", "Event 4"])
    }

    @Test("the cap counts resolved events, not configured slots")
    func capCountsResolvedEvents() {
        let many = (0 ..< 6).map { Fixtures.item(name: "Event \($0)") }
        let ids: [String?] = [nil, nil] + many.map(\.id.uuidString)

        #expect(DSItem.matching(ids: ids, in: many).count == 5)
    }

    @Test("the same event configured twice appears twice")
    func duplicateSlots() {
        let id = items[0].id.uuidString

        #expect(DSItem.matching(ids: [id, id], in: items).count == 2)
    }

    @Test("a widget with nothing configured resolves to no events")
    func noSlotsConfigured() {
        #expect(DSItem.matching(ids: [nil, nil, nil, nil, nil], in: items).isEmpty)
    }

    // MARK: - The store the widget reads

    /// The providers read items through `@AppStorage`, which stores arrays as JSON
    /// *strings* via `Array: RawRepresentable`. This is the exact path a widget takes.
    @Test("items written by the app decode through the RawRepresentable string path")
    func widgetReadPath() throws {
        let isolated = IsolatedDefaults()
        isolated.defaults.set(items.rawValue, forKey: "items")

        let raw = try #require(isolated.defaults.string(forKey: "items"))
        let decoded = try #require([DSItem](rawValue: raw))

        #expect(decoded.map(\.name) == ["Dentist", "Gym", "Haircut"])
        #expect(DSItem.first(matching: items[1].id.uuidString, in: decoded)?.name == "Gym")
    }

    @Test("a widget reading an unwritten key falls back to no events")
    func widgetReadPathMissingKey() {
        let isolated = IsolatedDefaults()

        #expect(isolated.defaults.string(forKey: "items") == nil)
        #expect([DSItem](rawValue: "") == nil)
    }
}
