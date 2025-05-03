//
//  SettingsReviewButton.swift
//  DaysSince
//
//  Created by Vicki Minerva on 6/30/22.
//

import Defaults
import SwiftUI

struct SettingsReviewButton: View {
    @Environment(\.openURL) var openURL
    @Default(.mainColor) var mainColor

    var body: some View {
        Button {
            Analytics.send(.settingsReview)
            if let url = URL(string: "https://apps.apple.com/us/app/days-since-track-memories/id1634218216?action=write-review") {
                openURL(url)
            }
        } label: {
            HStack {
                buttonImage
                buttonText
                Spacer()
                buttonShareArrow
            }
        }
        .foregroundColor(.primary)
    }

    var buttonImage: some View {
        LinearGradient(colors: [mainColor, mainColor.lighter()], startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(width: 34, height: 34)
            .cornerRadius(8)
            .overlay(
                Image(systemName: "star.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.white)
            )
            .padding(.leading, -10)
    }

    var buttonText: some View {
        Text("Review Days Since")
            .font(.system(.body, design: .rounded))
    }

    var buttonShareArrow: some View {
        Image(systemName: "arrow.up.forward.app.fill")
            .font(.title2)
            .foregroundColor(mainColor.darker())
            .opacity(0.5)
    }
}

struct SettingsReviewButton_Previews: PreviewProvider {
    static var previews: some View {
        SettingsReviewButton()
    }
}
