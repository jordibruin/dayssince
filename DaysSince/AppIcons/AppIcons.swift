//
//  AppIcons.swift
//  DaysSince
//
//  Created by Vicki Minerva on 6/29/22.
//

import Defaults
import SwiftUI

struct AppIcons: View {
    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var store: Store
    @EnvironmentObject var reviewManager: ReviewManager

    @Default(.mainColor) var mainColor

    var columns: [GridItem] = [
        GridItem(.flexible(minimum: 100), spacing: 10),
        GridItem(.flexible(minimum: 100), spacing: 10),
        GridItem(.flexible(minimum: 100), spacing: 10),
    ]

    var alternativeIcons: [AlternativeIcon] = [
        AlternativeIcon(name: "calendar-purple-image", iconName: "calendar-purple", premium: false, original: true),
        AlternativeIcon(name: "calendar-pink-image", iconName: "calendar-pink", premium: false, original: false),
        AlternativeIcon(name: "calendar-orange-image", iconName: "calendar-orange", premium: false, original: false),
        AlternativeIcon(name: "calendar-blue-image", iconName: "calendar-blue", premium: false, original: false),
        AlternativeIcon(name: "AppIcon-image", iconName: "AppIcon", premium: false, original: false),
    ]

    @State var showPayWall = false

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(alternativeIcons) { icon in
                    iconView(icon: icon)
                }
            }
            .padding(.horizontal)
            .offset(y: 20)
        }
        .navigationTitle("App Icons")
        .navigationBarTitleDisplayMode(.inline)
//        .sheet(isPresented: $showPayWall) {
//            PurchasesView(inOnboarding: false)
//        }
    }

    func iconView(icon: AlternativeIcon) -> some View {
        Button {
            
            Analytics.send(.chooseIcon, with: ["iconName": icon.iconName])
            
            if icon.iconName == UIApplication.shared.alternateIconName {
                return
            }

            if icon.original {
                UIApplication.shared.setAlternateIconName(nil) { error in
                    if let error = error {
                        print("Errorrr")
                        print(error.localizedDescription)
                        return
                    }
                }
            } else {
                if icon.premium {
//                    if !store.hasFullAccess {
//                        Analytics.hit(.proIcons)
//                        showPayWall = true
//                        return
//                    }
                }
                UIApplication.shared.setAlternateIconName(icon.iconName) { error in
                    if let error = error {
                        print("ERROR IS HERE")
                        print(error.localizedDescription)
                        return
                    }

                    self.reviewManager.promptReviewAlert()
                }
            }

        } label: {
            Image(icon.name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .shadow(color: mainColor.opacity(0.1), radius: 5, x: 0, y: 0)
                        }
                        .padding(8)

                        Spacer()
                    }
                    .opacity(showCheckmark(icon: icon) ? 1 : 0)
//                        .opacity(icon.original ? UIApplication.shared.alternateIconName == nil ? 1 : 0 UIApplication.shared.alternateIconName == icon.iconName ? 1 : 0)
                )
        }
    }

    func showCheckmark(icon: AlternativeIcon) -> Bool {
        if icon.original {
            return UIApplication.shared.alternateIconName == nil
        } else {
            return UIApplication.shared.alternateIconName == icon.iconName
        }
    }
}

struct AppIcons_Previews: PreviewProvider {
    static var previews: some View {
        AppIcons()
    }
}
