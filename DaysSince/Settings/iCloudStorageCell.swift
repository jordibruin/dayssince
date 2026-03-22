//
//  iCloudStorageCell.swift
//  DaysSince
//
//  Created by Victoria Petrova on 22/03/2026.
//

import Defaults
import SwiftUI

struct iCloudStorageCell: View {
    @EnvironmentObject var dataSyncManager: DataSyncManager

    @Default(.mainColor) var mainColor

    private var usageBytes: Int {
        dataSyncManager.iCloudUsageBytes
    }

    private var usageFraction: Double {
        Double(usageBytes) / Double(DataSyncManager.iCloudKVSLimit)
    }

    private var formattedUsage: String {
        let usageKB = Double(usageBytes) / 1024.0
        let limitKB = Double(DataSyncManager.iCloudKVSLimit) / 1024.0
        if usageKB < 1 {
            return String(format: "%d B / %.0f KB", usageBytes, limitKB)
        }
        return String(format: "%.1f KB / %.0f KB", usageKB, limitKB)
    }

    private var barColor: Color {
        if usageBytes >= DataSyncManager.iCloudKVSWarningThreshold {
            return .red
        } else if usageFraction > 0.7 {
            return .orange
        } else {
            return mainColor
        }
    }

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "icloud")
                        .foregroundColor(mainColor)
                        .font(.system(.body, design: .rounded))
                    Text("iCloud Storage")
                        .font(.system(.body, design: .rounded))
                    Spacer()
                    Text(formattedUsage)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [barColor, barColor.lighter()],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: max(geometry.size.width * usageFraction, 0),
                                height: 8
                            )
                    }
                }
                .frame(height: 8)
            }
            .padding(.vertical, 4)
        } footer: {
            Text("Events and categories are synced to iCloud (1 MB limit)")
                .font(Font.system(.body, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, -8)
        }
    }
}
