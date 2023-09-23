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

    @Binding var isDaysDisplayModeDetailed: Bool

    var body: some View {
        NavigationView {
            List {
//                daysSinceProSection
                appIconsSection

                MainAppColorPicker()
                DetailedTimeDisplayModeCell(isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed)

                Section {
                    SettingsReviewButton()
                    ShareButton()
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
                            .foregroundColor(Color.workColor.opacity(0.8))
                            .accessibilityLabel("Dismiss")
                    }
                }
            })
        }
        .accentColor(Color.workColor.darker())
    }

    var daysSinceProSection: some View {
        Section {
            Button {
//                Analytics.hit(.proSettings)
//                showPaywall = true
            } label: {}
                .frame(height: 120)
                .listRowBackground(
                    ZStack(alignment: .leading) {
                        Color.workColor

                        Text("Days Since\nPro")
                            .font(.system(.title, design: .rounded))
                            .bold()
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.leading)
                    }
                    .frame(height: 120)
                    .accessibilityElement()
                    .accessibilityLabel("Days Since Pro")
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
//        .sheet(isPresented: $showPaywall) {
//            PurchasesView(inOnboarding: false)
//        }
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
            Text("Thank you for using Days Since! ❤️")
            Spacer()
        }
        .padding(.top, 0)
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen(isDaysDisplayModeDetailed: .constant(false))
    }
}
