//
//  ShareButton.swift
//  DaysSince
//
//  Created by Vicki Minerva on 6/30/22.
//

import Defaults
import SwiftUI

struct ShareButton: View {
    @State var showShare = false

    @Default(.mainColor) var mainColor

    var body: some View {
        Button {
            Analytics.send(.settingsReview)
            showShare = true
        } label: {
            HStack {
                buttonImage
                buttonText
                Spacer()
                buttonShareArrow
            }
        }
        .foregroundColor(.primary)
        .sheet(isPresented: $showShare) {
            ShareSheet(items: [URL(string: "https://twitter.com/DaysSince_App")!])
        }
    }

    var buttonImage: some View {
        LinearGradient(colors: [mainColor, mainColor.lighter()], startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(width: 34, height: 34)
            .cornerRadius(8)
            .overlay(
                Image(systemName: "heart.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.white)
            )
            .padding(.leading, -10)
    }

    var buttonText: some View {
        Text("Share Days Since")
            .font(.system(.body, design: .rounded))
    }

    var buttonShareArrow: some View {
        Image(systemName: "arrow.up.forward.app.fill")
            .font(.title2)
            .foregroundColor(mainColor.darker())
            .opacity(0.5)
    }
}

struct ShareButton_Previews: PreviewProvider {
    static var previews: some View {
        ShareButton()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context _: Context) -> some UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) {}
}
