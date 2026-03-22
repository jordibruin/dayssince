//
//  iCloudMigrationView.swift
//  DaysSince
//
//  Created by Victoria Petrova on 21/03/2026.
//

import Defaults
import SwiftUI

/// Full-screen overlay shown to existing users on first launch after the iCloud update.
/// Displays progress while migrating UserDefaults data to iCloud.
struct iCloudMigrationView: View {
    @Default(.mainColor) var mainColor
    @Default(.backgroundColor) var backgroundColor
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject var dataSyncManager: DataSyncManager

    @Binding var iCloudMigrationComplete: Bool

    @State private var migrationDone = false
    @State private var itemCount = 0
    @State private var categoryCount = 0

    var body: some View {
        ZStack {
            background

            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 16) {
                    // Icon
                    Image(systemName: migrationDone ? "checkmark.icloud.fill" : "icloud.fill")
                        .font(.system(size: 60))
                        .foregroundColor(mainColor)
                        .contentTransition(.symbolEffect(.replace))

                    // Title
                    Text(migrationDone ? "All Done!" : "Syncing Your Events")
                        .font(.system(.title, design: .rounded))
                        .bold()

                    // Subtitle
                    Text(migrationDone
                         ? "\(itemCount) event\(itemCount == 1 ? "" : "s") and \(categoryCount) categor\(categoryCount == 1 ? "y" : "ies") synced to iCloud."
                         : "Your events and categories are being backed up to iCloud. This enables sync across your Apple devices.")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.primary.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)

                    // Progress indicator
                    if !migrationDone {
                        ProgressView()
                            .tint(mainColor)
                            .padding(.top, 8)
                    }
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 0)
                )
                .padding(.horizontal, 32)

                if migrationDone {
                    Spacer()
                    CustomButton(
                        action: { iCloudMigrationComplete = true },
                        label: "Continue",
                        color: mainColor
                    )
                    .transition(.opacity)
                }

                Spacer()
            }
        }
        .onAppear {
            performMigration()
        }
    }

    private var background: some View {
        Group {
            if colorScheme == .dark {
                Color(.systemBackground)
                    .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [backgroundColor.opacity(0.6), backgroundColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
        }
    }

    private func performMigration() {
        // Small delay so the user can read the message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let result = dataSyncManager.performMigration()

            withAnimation {
                itemCount = result.items
                categoryCount = result.categories
                migrationDone = true
            }
        }
    }
}
