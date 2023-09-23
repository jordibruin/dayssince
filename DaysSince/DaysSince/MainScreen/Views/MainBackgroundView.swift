//
//  MainBackgroundView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/23/22.
//

import SwiftUI

struct MainBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if colorScheme == .dark {
            Color.black
                .ignoresSafeArea()
        } else {
            LinearGradient(
                gradient: .init(colors: [Color.backgroundColor.opacity(0.0), Color.backgroundColor]),
                startPoint: .init(x: 1, y: 0),
                endPoint: .init(x: 0.0001, y: 0)
            )
            .ignoresSafeArea()
        }
    }
}

struct MainBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        MainBackgroundView()
    }
}
