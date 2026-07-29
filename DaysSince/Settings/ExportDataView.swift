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
            content = ExportFormatter.json(items: items, categories: categories)
        case .csv:
            content = ExportFormatter.csv(items: items)
        case .plainText:
            content = ExportFormatter.plainText(items: items, categories: categories)
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

}

