//
//  SettingsScreen.swift
//  DaysSince
//
//  Created by Vicki Minerva on 6/29/22.
//

import Defaults
import SwiftUI

struct SettingsScreen: View {
    @Default(.mainColor) var mainColor

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    @Binding var isDaysDisplayModeDetailed: Bool
    @Binding var showSettings: Bool

    @State private var showPaywall = false
    @State private var showExport = false

    #if DEBUG
    @State private var iCloudDataCleared = false
    #endif

    var body: some View {
        NavigationView {
            List {
                daysSinceProSection
                appIconsSection

                DetailedTimeDisplayModeCell(isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed)

                iCloudStorageCell()

                Section {
                    Button {
                        showExport = true
                    } label: {
                        HStack {
                            LinearGradient(
                                colors: [mainColor, mainColor.lighter()],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .frame(width: 34, height: 34)
                            .cornerRadius(8)
                            .overlay(
                                Image(systemName: "square.and.arrow.up")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundColor(.white)
                            )
                            Text("Export Data")
                                .font(.system(.body, design: .rounded))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                }
                .sheet(isPresented: $showExport) {
                    ExportDataView()
                }

                Section {
                    WebsiteButton()
                    TwitterButton()
                    PrivacyButton()
                    ShareButton()
                    SettingsReviewButton()
                    WishKitView()
                    SupportButton()
                } footer: {
                    footer
                }

                #if DEBUG
                Section("Debug") {
                    Button(role: .destructive) {
                        let store = NSUbiquitousKeyValueStore.default
                        store.removeObject(forKey: "items")
                        store.removeObject(forKey: "icloud_categories")
                        store.synchronize()
                        iCloudDataCleared = true
                    } label: {
                        Label("Clear iCloud Data", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    .alert("iCloud Data Cleared", isPresented: $iCloudDataCleared) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("Items and categories have been removed from iCloud KVS. Local data is unchanged.")
                    }
                }
                #endif
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
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
            })
        }
        .accentColor(mainColor.darker())
    }

    var daysSinceProSection: some View {
        Section {
            Button {
                Analytics.send(.proSettings)
                showPaywall = true
            } label: {
                HStack {
                    Label("Days Since Pro", systemImage: "star.fill")
                        .font(.system(.title3, design: .rounded))
                        .foregroundColor(mainColor)
                    Spacer()
                    if subscriptionManager.isSubscribed {
                        Text("Active")
                            .foregroundColor(.green)
                            .font(.system(.caption, design: .rounded))
                    } else {
                        Text("Upgrade")
                            .foregroundColor(mainColor)
                            .font(.system(.caption, design: .rounded))
                            .bold()
                    }
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallScreen(isDismissable: true)
        }
    }

    var appIconsSection: some View {
        Section {
            NavigationLink {
                AppIcons()
            } label: {
                HStack {
                    iconImage
                    Text("App Icons")
                        .font(.system(.title3, design: .rounded))
                        .padding(.leading, 8)
                    Spacer()
                }
            }
            .listRowInsets(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 16))
        }
    }

    @ViewBuilder
    var iconImage: some View {
        if let iconName = UIApplication.shared.alternateIconName {
            Image("\(iconName)-image")
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(12)
                .aspectRatio(contentMode: .fit)
                .grayscale(0)
        } else {
            Image("calendar-purple-image")
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(12)
                .aspectRatio(contentMode: .fit)
                .grayscale(0)
        }
    }

    var footer: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .center) {
                Text("\(Bundle.main.appVersion)")
                Text("Thank you for using Days Since! ❤️")
            }
            
            Spacer()
        }
        .padding(.top, 0)
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen(
            isDaysDisplayModeDetailed: .constant(false),
            showSettings: .constant(true)
        )
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
