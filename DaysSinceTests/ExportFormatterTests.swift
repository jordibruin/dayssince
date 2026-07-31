@testable import DaysSince
import Foundation
import Testing

/// Pure tier. Production formats dates in the user's locale, so every test here injects a
/// pinned `en_US_POSIX`/GMT formatter — otherwise the expected strings would depend on
/// where the test runs.
@Suite("Export formatter")
struct ExportFormatterTests {

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateStyle = .medium
        return formatter
    }()

    /// 1970-01-12T13:46:40Z, medium style in en_US_POSIX.
    private let referenceDateText = "Jan 12, 1970"

    // MARK: - CSV escaping

    @Test(
        "a value is quoted only when it contains a comma, quote or newline",
        arguments: [
            ("Dentist", "Dentist"),
            ("Dentist, again", "\"Dentist, again\""),
            ("He said \"hi\"", "\"He said \"\"hi\"\"\""),
            ("Line\nbreak", "\"Line\nbreak\""),
            ("", ""),
            ("🎉 party", "🎉 party"),
            ("a,\"b\"\nc", "\"a,\"\"b\"\"\nc\""),
            ("semi;colon", "semi;colon"),
        ]
    )
    func csvEscaping(value: String, expected: String) {
        #expect(ExportFormatter.csvEscape(value) == expected)
    }

    // MARK: - CSV

    @Test("csv always emits a header")
    func csvHeader() {
        let csv = ExportFormatter.csv(items: [], dateFormatter: formatter)

        #expect(csv == "Name,Category,Emoji,Date,Days Ago,Reminders,Reminder Frequency")
    }

    @Test("a row carries every column in header order")
    func csvRowColumns() throws {
        let item = Fixtures.item(
            name: "Dentist",
            category: Fixtures.category(name: "Health", emoji: "heart", color: .health),
            remindersEnabled: true,
            reminder: .weekly
        )

        let rows = ExportFormatter.csv(items: [item], dateFormatter: formatter).components(separatedBy: "\n")

        #expect(rows.count == 2)
        let row = try #require(rows.last)
        #expect(row == "Dentist,Health,heart,\"\(referenceDateText)\",\(item.daysAgo),Yes,weekly")
    }

    /// Medium style renders as "Jan 12, 1970" in most locales, so the date is the one field
    /// that carries a comma for *every* user rather than only for oddly-named events. It went
    /// out unescaped for years: the row then had 8 fields against a 7-column header and every
    /// spreadsheet shifted Days Ago onwards by one column.
    @Test("a date containing a comma stays a single field")
    func csvDateIsEscaped() throws {
        let csv = ExportFormatter.csv(items: [Fixtures.item(name: "Dentist")], dateFormatter: formatter)
        let rows = csv.components(separatedBy: "\n")
        let header = try #require(rows.first)
        let row = try #require(rows.last)

        #expect(referenceDateText.contains(","))
        #expect(row.contains("\"\(referenceDateText)\""))
        #expect(fieldCount(of: row) == fieldCount(of: header))
    }

    /// Counts comma-separated fields the way a CSV reader does: commas inside a quoted field
    /// are literal. Splitting on "," alone is exactly the mistake this test exists to catch.
    private func fieldCount(of row: String) -> Int {
        var fields = 1
        var insideQuotes = false
        for character in row {
            switch character {
            case "\"": insideQuotes.toggle()
            case "," where !insideQuotes: fields += 1
            default: break
            }
        }
        return fields
    }

    @Test("an item without reminders leaves the frequency column empty")
    func csvOmitsFrequencyWhenRemindersOff() throws {
        let item = Fixtures.item(remindersEnabled: false, reminder: .monthly)

        let row = try #require(ExportFormatter.csv(items: [item], dateFormatter: formatter).components(separatedBy: "\n").last)

        #expect(row.hasSuffix(",No,"))
    }

    @Test("rows are sorted by category name")
    func csvSortsByCategoryName() {
        let items = [
            Fixtures.item(name: "Walk", category: Fixtures.category(stableID: "z", name: "Zoo")),
            Fixtures.item(name: "Code", category: Fixtures.category(stableID: "a", name: "Apps")),
        ]

        let rows = ExportFormatter.csv(items: items, dateFormatter: formatter).components(separatedBy: "\n").dropFirst()

        #expect(rows.map { String($0.prefix(4)) } == ["Code", "Walk"])
    }

    /// `sorted(by:)` is not stable, so a single sort key leaves events sharing that key in
    /// whatever order the sort happens to land on. Asserted by sorting the same set twice from
    /// different starting orders: with only `category.name` as the key these two disagree.
    @Test("rows sharing a category are ordered by name, not by input order")
    func csvSortIsDeterministic() {
        let shared = Fixtures.category(stableID: "a", name: "Apps")
        let forward = [
            Fixtures.item(name: "Alpha", category: shared),
            Fixtures.item(name: "Beta", category: shared),
            Fixtures.item(name: "Gamma", category: shared),
        ]

        let names: ([DSItem]) -> [String] = { items in
            ExportFormatter.csv(items: items, dateFormatter: self.formatter)
                .components(separatedBy: "\n")
                .dropFirst()
                .map { String($0.prefix(while: { $0 != "," })) }
        }

        #expect(names(forward) == ["Alpha", "Beta", "Gamma"])
        #expect(names(forward.reversed()) == ["Alpha", "Beta", "Gamma"])
    }

    @Test("a name containing a comma does not add a column")
    func csvEscapesNameInRow() throws {
        let item = Fixtures.item(name: "Dentist, again")

        let row = try #require(ExportFormatter.csv(items: [item], dateFormatter: formatter).components(separatedBy: "\n").last)

        #expect(row.hasPrefix("\"Dentist, again\","))
    }

    // MARK: - JSON

    @Test("json re-decodes into the original events and categories")
    func jsonRoundTrips() throws {
        let categories = [Fixtures.category(name: "Work"), Fixtures.category(stableID: "life", name: "Life")]
        let items = [Fixtures.item(name: "Dentist"), Fixtures.item(name: "Gym")]

        let json = ExportFormatter.json(items: items, categories: categories, exportDate: Fixtures.referenceDate)
        let data = try #require(json.data(using: .utf8))

        struct Decoded: Decodable {
            let exportDate: Date
            let categories: [DaysSince.Category]
            let events: [DSItem]
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Decoded.self, from: data)

        #expect(decoded.events.map(\.name) == ["Dentist", "Gym"])
        #expect(decoded.categories.map(\.name) == ["Work", "Life"])
        #expect(decoded.exportDate == Fixtures.referenceDate)
    }

    @Test("json keys are sorted and pretty printed")
    func jsonFormatting() throws {
        let json = ExportFormatter.json(items: [Fixtures.item()], categories: [], exportDate: Fixtures.referenceDate)

        #expect(json.contains("\n"))
        let keyOrder = ["\"categories\"", "\"events\"", "\"exportDate\""]
        let positions = try keyOrder.map { try #require(json.range(of: $0)?.lowerBound) }
        #expect(positions == positions.sorted())
    }

    @Test("the export date is written as ISO8601")
    func jsonExportDateIsISO8601() {
        let json = ExportFormatter.json(items: [], categories: [], exportDate: Fixtures.referenceDate)

        #expect(json.contains("\"exportDate\" : \"1970-01-12T13:46:40Z\""))
    }

    @Test("an empty export is still valid json")
    func jsonEmptyExport() throws {
        let json = ExportFormatter.json(items: [], categories: [], exportDate: Fixtures.referenceDate)
        let data = try #require(json.data(using: .utf8))

        let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect((object["events"] as? [Any])?.isEmpty == true)
        #expect((object["categories"] as? [Any])?.isEmpty == true)
    }

    // MARK: - Plain text

    @Test("plain text opens with a header and closes with a count")
    func plainTextHeaderAndFooter() throws {
        let text = ExportFormatter.plainText(
            items: [Fixtures.item()],
            categories: [Fixtures.category()],
            exportDate: Fixtures.referenceDate,
            dateFormatter: formatter
        )
        let lines = text.components(separatedBy: "\n")

        #expect(lines.first == "DAYS SINCE — Export")
        #expect(lines[1] == "Exported on \(referenceDateText)")
        #expect(lines.last == "1 events in 1 categories")
    }

    @Test("categories are grouped in sort order")
    func plainTextGroupsBySortOrder() throws {
        let work = Fixtures.category(stableID: "work", name: "Work", sortOrder: 2)
        let life = Fixtures.category(stableID: "life", name: "Life", sortOrder: 1)
        let items = [Fixtures.item(name: "Standup", category: work), Fixtures.item(name: "Laundry", category: life)]

        let text = ExportFormatter.plainText(
            items: items,
            categories: [work, life],
            exportDate: Fixtures.referenceDate,
            dateFormatter: formatter
        )

        let lifeIndex = try #require(text.range(of: "Life")?.lowerBound)
        let workIndex = try #require(text.range(of: "Work")?.lowerBound)
        #expect(lifeIndex < workIndex)
    }

    @Test("grouping is by stableID, not category name")
    func plainTextGroupsByStableID() {
        // The stored item carries an outdated copy of the renamed category.
        let renamed = Fixtures.category(stableID: "work", name: "Career", sortOrder: 0)
        let stale = Fixtures.category(stableID: "work", name: "Work", sortOrder: 0)
        let item = Fixtures.item(name: "Standup", category: stale)

        let text = ExportFormatter.plainText(
            items: [item],
            categories: [renamed],
            exportDate: Fixtures.referenceDate,
            dateFormatter: formatter
        )

        #expect(text.contains("Career"))
        #expect(text.contains("  Standup —"))
        #expect(!text.contains("📋 Other"))
    }

    @Test("events within a category are listed oldest first")
    func plainTextSortsByDaysAgoDescending() throws {
        let category = Fixtures.category()
        let items = [
            Fixtures.item(name: "Recent", category: category, dateLastDone: Fixtures.newerDate),
            Fixtures.item(name: "Older", category: category, dateLastDone: Fixtures.olderDate),
        ]

        let text = ExportFormatter.plainText(
            items: items,
            categories: [category],
            exportDate: Fixtures.referenceDate,
            dateFormatter: formatter
        )

        let older = try #require(text.range(of: "Older")?.lowerBound)
        let recent = try #require(text.range(of: "Recent")?.lowerBound)
        #expect(older < recent)
    }

    @Test("events sharing a date are ordered by name, not by input order")
    func plainTextSortIsDeterministic() {
        let category = Fixtures.category()
        let items = [
            Fixtures.item(name: "Alpha", category: category, dateLastDone: Fixtures.olderDate),
            Fixtures.item(name: "Beta", category: category, dateLastDone: Fixtures.olderDate),
        ]

        let eventLines: ([DSItem]) -> [String] = { items in
            ExportFormatter.plainText(
                items: items,
                categories: [category],
                exportDate: Fixtures.referenceDate,
                dateFormatter: self.formatter
            )
            .components(separatedBy: "\n")
            .filter { $0.hasPrefix("  ") }
            .map { $0.trimmingCharacters(in: .whitespaces).components(separatedBy: " —")[0] }
        }

        #expect(eventLines(items) == ["Alpha", "Beta"])
        #expect(eventLines(items.reversed()) == ["Alpha", "Beta"])
    }

    @Test("an event line carries the name, day count and date")
    func plainTextEventLine() throws {
        let item = Fixtures.item(name: "Dentist")

        let text = ExportFormatter.plainText(
            items: [item],
            categories: [item.category],
            exportDate: Fixtures.referenceDate,
            dateFormatter: formatter
        )

        #expect(text.contains("  Dentist — \(item.daysAgo) days ago (\(referenceDateText))"))
    }

    @Test("an event whose category was deleted lands under Other")
    func plainTextOrphansGoToOther() {
        let orphan = Fixtures.item(name: "Ghost", category: Fixtures.category(stableID: "gone", name: "Gone"))

        let text = ExportFormatter.plainText(
            items: [orphan],
            categories: [Fixtures.category()],
            exportDate: Fixtures.referenceDate,
            dateFormatter: formatter
        )

        #expect(text.contains("📋 Other"))
        #expect(text.contains("  Ghost —"))
    }

    @Test("a category with no events is omitted")
    func plainTextSkipsEmptyCategories() {
        let text = ExportFormatter.plainText(
            items: [],
            categories: [Fixtures.category(name: "Work")],
            exportDate: Fixtures.referenceDate,
            dateFormatter: formatter
        )

        #expect(!text.contains("Work"))
        #expect(!text.contains("📋 Other"))
        #expect(text.hasSuffix("0 events in 1 categories"))
    }

    @Test("an empty export still produces a header and footer")
    func plainTextEmptyExport() {
        let text = ExportFormatter.plainText(
            items: [],
            categories: [],
            exportDate: Fixtures.referenceDate,
            dateFormatter: formatter
        )

        #expect(text.hasPrefix("DAYS SINCE — Export"))
        #expect(text.hasSuffix("0 events in 0 categories"))
    }

    // MARK: - File extensions

    @Test(
        "each format writes its own file extension",
        arguments: [(ExportFormat.json, "json"), (.csv, "csv"), (.plainText, "txt")]
    )
    func fileExtensions(format: ExportFormat, expected: String) {
        #expect(format.fileExtension == expected)
    }
}
