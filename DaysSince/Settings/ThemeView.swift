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

    let colorThemes: [ColorTheme] = [
        ColorTheme(mainColor: .workColor.darker(by: 0.02), backgroundColor: .backgroundColor),
        ColorTheme(mainColor: .healthColor.darker(by: 0.2), backgroundColor: .healthColor.lighter(by: 0.4)),
        ColorTheme(mainColor: .lifeColor.darker(by: 0.2), backgroundColor: .lifeColor.lighter(by: 0.4)),
        ColorTheme(mainColor: .hobbiesColor.darker(by: 0.2), backgroundColor: .hobbiesColor.lighter(by: 0.4)),
        ColorTheme(mainColor: .zeldaGreen.darker(by: 0.1), backgroundColor: .zeldaYellow),
        ColorTheme(mainColor: .black, backgroundColor: .backgroundColor),
        ColorTheme(mainColor: .marioRed, backgroundColor: .marioBlue.lighter(by: 0.6)),
        ColorTheme(mainColor: .peachDarkPink.darker(by: 0.1), backgroundColor: .peachLightPink),
//        ColorTheme(mainColor: .green, backgroundColor: .brown.lighter(by: 0.6)),
        ColorTheme(mainColor: .marioRed, backgroundColor: .marioRed.lighter(by: 0.8)),
        ColorTheme(mainColor: .animalCrossingsBrown, backgroundColor: .animalCrossingsGreen.lighter(by: 0.6)),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Spacer()
                Text("Colors")
                    .font(.system(.headline, design: .rounded))
                    .bold()
                    .padding(.horizontal, 24)
                Spacer()
            }

            .padding(.top, 20)

            LazyVGrid(
                columns: columns,
                alignment: .center,
                spacing: 20
            ) {
                ForEach(colorThemes, id: \.self) { colorTheme in
                    ColorThemeView(
                        mainColorTemporary: colorTheme.mainColor,
                        backgroundColorTemporary: colorTheme.backgroundColor
                    )
                }
            }
            .padding()

            Spacer()
        }
    }
}

struct ColorTheme: Equatable, Hashable {
    let mainColor: Color
    let backgroundColor: Color

    // Implement the equality operator
    static func == (lhs: ColorTheme, rhs: ColorTheme) -> Bool {
        return lhs.mainColor == rhs.mainColor && lhs.backgroundColor == rhs.backgroundColor
    }
}

struct ThemeView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeView()
    }
}
