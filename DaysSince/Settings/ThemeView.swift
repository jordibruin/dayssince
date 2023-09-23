//
//  ThemeView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 9/24/23.
//

import SwiftUI

struct ThemeView: View {
    var columns: [GridItem] = [
        GridItem(.flexible(minimum: 56), spacing: 10),
        GridItem(.flexible(minimum: 56), spacing: 10),
        GridItem(.flexible(minimum: 56), spacing: 10),
        GridItem(.flexible(minimum: 56), spacing: 10),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Colors")
                    .font(.system(.title2, design: .rounded))
                    .bold()
                    .padding(.horizontal, 24)
            }

            .padding(.top, 8)

            LazyVGrid(
                columns: columns,
                alignment: .center,
                spacing: 20
            ) {
                ColorThemeView(mainColorTemporary: Color.workColor, backgroundColorTemporary: Color.backgroundColor)
                ColorThemeView(mainColorTemporary: Color.lifeColor, backgroundColorTemporary: Color.lifeColor)
                ColorThemeView(mainColorTemporary: Color.healthColor, backgroundColorTemporary: Color.healthColor)
                ColorThemeView(mainColorTemporary: Color.hobbiesColor, backgroundColorTemporary: Color.hobbiesColor)
                ColorThemeView(mainColorTemporary: Color.black, backgroundColorTemporary: Color.pink)
                ColorThemeView(mainColorTemporary: Color.yellow, backgroundColorTemporary: Color.gray)
            }
            .padding()

            Spacer()
        }
    }
}

struct ThemeView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeView()
    }
}
