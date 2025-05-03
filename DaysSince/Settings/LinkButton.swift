//
//  FollowButton.swift
//  DaysSince
//
//  Created by Victoria Petrova on 03/05/2025.
//

import Defaults
import SwiftUI


struct TwitterButton: View {
    var body: some View {
        LinkButton(
            title: "Follow on Twitter",
            symbolName: "bird.fill",
            urlString: "https://twitter.com/h"
        )
    }
}

struct WebsiteButton: View {
    var body: some View {
        LinkButton(
            title: "Website",
            symbolName: "globe",
            urlString: "https://dayssince-website.vercel.app/"
        )
    }
}

struct PrivacyButton: View {
    var body: some View {
        LinkButton(
            title: "Privacy Policy",
            symbolName: "lock.fill",
            urlString: "https://dayssince-website.vercel.app/#privacy"
        )
    }
}

struct LinkButton: View {
    @Default(.mainColor) var mainColor
    @Environment(\.openURL) var openURL

    let title: String
    let symbolName: String
    let urlString: String

    var body: some View {
        Button {
            if let url = URL(string: urlString) {
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
                Image(systemName: symbolName)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.white)
            )
            .padding(.leading, -10)
    }

    var buttonText: some View {
        Text(title)
            .font(.system(.body, design: .rounded))
    }

    var buttonShareArrow: some View {
        Image(systemName: "arrow.up.forward.app.fill")
            .font(.title2)
            .foregroundColor(mainColor.darker())
            .opacity(0.5)
    }
}

struct LinkButton_Preview: PreviewProvider {
    static var previews: some View {
        LinkButton(title: "Follow on Twitter",
                   symbolName: "bird.fill",
                   urlString: "https://twitter.com/YourAppHandle")
    }
}
