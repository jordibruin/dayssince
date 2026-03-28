//
//  ExportDataView.swift
//  DaysSince
//
//  Created by Victoria Petrova on 28/03/2026.
//

import Defaults
import SwiftUI

enum ExportFormat: String, CaseIterable, Identifiable {
    case json = "JSON"
    case csv = "CSV"
    case plainText = "Plain Text"

    var id: String { rawValue }

    var fileExtension: String {
        switch self {
        case .json: return "json"
        case .csv: return "csv"
        case .plainText: return "txt"
        }
    }

    var systemImage: String {
        switch self {
        case .json: return "curlybraces"
        case .csv: return "tablecells"
        case .plainText: return "doc.text"
        }
    }
}

struct ExportDataView: View {
    @EnvironmentObject var dataSyncManager: DataSyncManager

    @Default(.mainColor) var mainColor

    @Environment(\.dismiss) var dismiss

    @State private var exportURL: URL?
    @State private var showShareSheet = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(ExportFormat.allCases) { format in
                        Button {
                            exportData(format: format)
                        } label: {
                            HStack {
                                formatIcon(for: format)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(format.rawValue)
                                        .font(.system(.body, design: .rounded))
                                    Text(formatDescription(for: format))
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(mainColor)
                                    .font(.body)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                } header: {
                    Text("Choose a format")
                        .font(.system(.caption, design: .rounded))
                } footer: {
                    Text("\(dataSyncManager.items.count) events in \(dataSyncManager.categories.count) categories")
                        .font(.system(.caption, design: .rounded))
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.title2)
                            .foregroundColor(mainColor.opacity(0.8))
                            .accessibilityLabel("Dismiss")
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    private func formatIcon(for format: ExportFormat) -> some View {
        LinearGradient(
            colors: [mainColor, mainColor.lighter()],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(width: 34, height: 34)
        .cornerRadius(8)
        .overlay(
            Image(systemName: format.systemImage)
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.white)
        )
    }

    private func formatDescription(for format: ExportFormat) -> String {
        switch format {
        case .json:
            return "Machine-readable backup format"
        case .csv:
            return "Open in Excel, Numbers, or Google Sheets"
        case .plainText:
            return "Human-readable text file"
        }
    }

    // MARK: - Export Logic

    private func exportData(format: ExportFormat) {
        let items = dataSyncManager.items
        let categories = dataSyncManager.categories

        let content: String
        switch format {
        case .json:
            content = generateJSON(items: items, categories: categories)
        case .csv:
            content = generateCSV(items: items)
        case .plainText:
            content = generatePlainText(items: items, categories: categories)
        }

        let fileName = "DaysSince_Export.\(format.fileExtension)"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try content.write(to: tempURL, atomically: true, encoding: .utf8)
            Analytics.send(.exportData, with: ["format": format.rawValue])
            exportURL = tempURL
            showShareSheet = true
        } catch {
            print("Export failed: \(error.localizedDescription)")
        }
    }

    private func generateJSON(items: [DSItem], categories: [Category]) -> String {
        struct ExportData: Encodable {
            let exportDate: Date
            let categories: [Category]
            let events: [DSItem]
        }

        let exportData = ExportData(
            exportDate: .now,
            categories: categories,
            events: items
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(exportData),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }

    private func generateCSV(items: [DSItem]) -> String {
        var lines = ["Name,Category,Emoji,Date,Days Ago,Reminders,Reminder Frequency"]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

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

    private func csvEscape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }

    private func generatePlainText(items: [DSItem], categories: [Category]) -> String {
        var lines: [String] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        lines.append("DAYS SINCE — Export")
        lines.append("Exported on \(dateFormatter.string(from: .now))")
        lines.append(String(repeating: "—", count: 40))
        lines.append("")

        let grouped = Dictionary(grouping: items) { $0.category.stableID }

        for category in categories.sorted(by: { $0.sortOrder < $1.sortOrder }) {
            guard let categoryItems = grouped[category.stableID], !categoryItems.isEmpty else { continue }

            lines.append("\(category.emoji) \(category.name)")
            lines.append(String(repeating: "-", count: 30))

            for item in categoryItems.sorted(by: { $0.daysAgo > $1.daysAgo }) {
                let date = dateFormatter.string(from: item.dateLastDone)
                lines.append("  \(item.name) — \(item.daysAgo) days ago (\(date))")
            }
            lines.append("")
        }

        // Include uncategorized items (items whose category isn't in the categories list)
        let knownStableIDs = Set(categories.map(\.stableID))
        let uncategorized = items.filter { !knownStableIDs.contains($0.category.stableID) }
        if !uncategorized.isEmpty {
            lines.append("📋 Other")
            lines.append(String(repeating: "-", count: 30))
            for item in uncategorized.sorted(by: { $0.daysAgo > $1.daysAgo }) {
                let date = dateFormatter.string(from: item.dateLastDone)
                lines.append("  \(item.name) — \(item.daysAgo) days ago (\(date))")
            }
            lines.append("")
        }

        lines.append(String(repeating: "—", count: 40))
        lines.append("\(items.count) events in \(categories.count) categories")

        return lines.joined(separator: "\n")
    }
}

