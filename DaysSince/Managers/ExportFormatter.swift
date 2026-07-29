//
//  ExportFormatter.swift
//  DaysSince
//

import Foundation

/// Serializes events and categories for the export sheet. Extracted from `ExportDataView`
/// so the formats can be tested; lives in `Managers` because that folder is a
/// file-system-synchronized group and `Settings` is not.
enum ExportFormatter {

    /// Medium style in the user's locale — what the app exports with. Callers can pass a
    /// pinned formatter instead when the output shape has to be stable.
    static var defaultDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    static func json(
        items: [DSItem],
        categories: [Category],
        exportDate: Date = .now
    ) -> String {
        struct ExportData: Encodable {
            let exportDate: Date
            let categories: [Category]
            let events: [DSItem]
        }

        let exportData = ExportData(exportDate: exportDate, categories: categories, events: items)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(exportData),
              let string = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return string
    }

    static func csv(items: [DSItem], dateFormatter: DateFormatter? = nil) -> String {
        let dateFormatter = dateFormatter ?? defaultDateFormatter
        var lines = ["Name,Category,Emoji,Date,Days Ago,Reminders,Reminder Frequency"]

        for item in items.sorted(by: { $0.category.name < $1.category.name }) {
            let name = csvEscape(item.name)
            let category = csvEscape(item.category.name)
            let emoji = item.emoji
            let date = dateFormatter.string(from: item.dateLastDone)
            let daysAgo = "\(item.daysAgo)"
            let reminders = item.remindersEnabled ? "Yes" : "No"
            let frequency = item.remindersEnabled ? "\(item.reminder)" : ""
            lines.append("\(name),\(category),\(emoji),\(date),\(daysAgo),\(reminders),\(frequency)")
        }

        return lines.joined(separator: "\n")
    }

    static func csvEscape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }

    static func plainText(
        items: [DSItem],
        categories: [Category],
        exportDate: Date = .now,
        dateFormatter: DateFormatter? = nil
    ) -> String {
        let dateFormatter = dateFormatter ?? defaultDateFormatter
        var lines: [String] = []

        lines.append("DAYS SINCE — Export")
        lines.append("Exported on \(dateFormatter.string(from: exportDate))")
        lines.append(String(repeating: "—", count: 40))
        lines.append("")

        let grouped = Dictionary(grouping: items) { $0.category.stableID }

        for category in categories.sorted(by: { $0.sortOrder < $1.sortOrder }) {
            guard let categoryItems = grouped[category.stableID], !categoryItems.isEmpty else { continue }

            lines.append("\(category.emoji) \(category.name)")
            lines.append(String(repeating: "-", count: 30))
            lines.append(contentsOf: entries(for: categoryItems, dateFormatter: dateFormatter))
            lines.append("")
        }

        // Items whose category isn't in the categories list.
        let knownStableIDs = Set(categories.map(\.stableID))
        let uncategorized = items.filter { !knownStableIDs.contains($0.category.stableID) }
        if !uncategorized.isEmpty {
            lines.append("📋 Other")
            lines.append(String(repeating: "-", count: 30))
            lines.append(contentsOf: entries(for: uncategorized, dateFormatter: dateFormatter))
            lines.append("")
        }

        lines.append(String(repeating: "—", count: 40))
        lines.append("\(items.count) events in \(categories.count) categories")

        return lines.joined(separator: "\n")
    }

    private static func entries(for items: [DSItem], dateFormatter: DateFormatter) -> [String] {
        items
            .sorted { $0.daysAgo > $1.daysAgo }
            .map { "  \($0.name) — \($0.daysAgo) days ago (\(dateFormatter.string(from: $0.dateLastDone)))" }
    }
}
