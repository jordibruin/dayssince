//
//  SupportItemPageView.swift
//  Supporter
//
//  Created by Jordi Bruin on 01/12/2021.
//

import AVKit
import SwiftUI

struct SupportItemPageView: View {
    @Environment(\.colorScheme) var colorScheme
    let page: SupportItemPage
    @State private var player: AVPlayer?

    // Used to pause and play when the page appears
    @State var stopPlayer: Bool = false

    // The videos are muted by default
    @State var muted: Bool = false

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                if page.videoURL != nil {
                    video
                        .frame(height: geo.size.height * 5 / 9)
                } else if page.imageURL != nil {
                    image
                        .frame(width: geo.size.width)
//                    .frame(height: geo.size.height * 5/9)
                } else {
                    Color(.systemBackground)
                }

                explanation
            }
        }
        .onAppear {
            stopPlayer = false
        }
        .onDisappear {
            stopPlayer = true
        }
    }

    var video: some View {
        ZStack(alignment: .top) {
            Color(.systemBackground)

            SupporterVideoPlayerController(
                videoURL: URL(string: themeVideo()!)!,
                stopPlayer: $stopPlayer,
                muted: $muted
            )
        }
        .background(Design.backgroundColor)
    }

    var image: some View {
        AsyncImage(url: URL(string: themeImage()!)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(Rectangle())
        } placeholder: {
            Design.backgroundColor
        }
    }

    var explanation: some View {
        return ZStack(alignment: .topLeading) {
            Design.backgroundColor
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(page.title)
                        .font(.system(.title2, design: .rounded))
                        .bold()

                    Text(page.subtitle)
                        .font(.system(.title3, design: .rounded))
                }
                .padding(24)
            }
        }
    }

    func themeVideo() -> String? {
        if colorScheme == .dark {
            if page.darkImageURL != nil {
                return page.darkVideoURL
            } else {
                return page.videoURL
            }
        } else {
            return page.videoURL
        }
    }

    func themeImage() -> String? {
        if colorScheme == .dark {
            if page.darkImageURL != nil {
                return page.darkImageURL
            } else {
                return page.imageURL
            }
        } else {
            return page.imageURL
        }
    }
}

struct SupportItemPageView_Previews: PreviewProvider {
    static var previews: some View {
        SupportItemPageView(page: SupportItemPage(id: 1, title: "Title", subtitle: "subtitle", videoURL: nil, imageURL: nil))
    }
}
