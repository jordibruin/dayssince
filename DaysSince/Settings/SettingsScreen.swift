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
    @EnvironmentObject var entitlements: Entitlements

    @Binding var isDaysDisplayModeDetailed: Bool
    @Binding var showSettings: Bool

    @State private var showPaywall: Bool = false

    var body: some View {
        NavigationView {
            List {
                daysSinceProSection
                appIconsSection

                DetailedTimeDisplayModeCell(isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed)

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
        .sheet(isPresented: $showPaywall) {
            PayWallScreen(inOnboarding: false)
        }
    }

    var daysSinceProSection: some View {
        Section {
            Button {
                showPaywall = true
            } label: {
            }
            .frame(height: 120)
            .listRowBackground(
                ZStack(alignment: .leading) {
                    proBackground
                        .frame(height: 120)
                        .cornerRadius(20)

                    Text("Days Since\nPro")
                        .font(.system(.title, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading)
                        .accessibilityLabel("Days Since Pro")
                }
                .frame(height: 120)
                .cornerRadius(20)
            )
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }

    @ViewBuilder
    private var proBackground: some View {
        if entitlements.isPro {
            LinearGradient(
                colors: [mainColor, mainColor.lighter()],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            mainColor
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
        .environmentObject(StoreManager())
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}


