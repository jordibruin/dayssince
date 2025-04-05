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
        ColorTheme(id: "default", mainColor: .workColor.darker(by: 0.02), backgroundColor: .backgroundColor),
        ColorTheme(id: "blackWhite", mainColor: .black, backgroundColor: .white),
        ColorTheme(id: "health", mainColor: .healthColor.darker(by: 0.2), backgroundColor: .healthColor.lighter(by: 0.4)),
        ColorTheme(id: "life", mainColor: .lifeColor.darker(by: 0.2), backgroundColor: .lifeColor.lighter(by: 0.4)),
        ColorTheme(id: "hobbies", mainColor: .hobbiesColor.darker(by: 0.2), backgroundColor: .hobbiesColor.lighter(by: 0.4)),
        ColorTheme(id: "zelda", mainColor: .black, backgroundColor: .zeldaYellow.lighter(by: 0.6)),
        ColorTheme(id: "blackDefaultBackground", mainColor: .black, backgroundColor: .backgroundColor),
        ColorTheme(id: "marioRedBlue", mainColor: .marioRed, backgroundColor: .marioBlue.lighter(by: 0.6)),
        ColorTheme(id: "peachPink", mainColor: .peachDarkPink.darker(by: 0.1), backgroundColor: .peachLightPink),
//        ColorTheme(mainColor: .green, backgroundColor: .brown.lighter(by: 0.6)),
        ColorTheme(id: "marioRed", mainColor: .marioRed, backgroundColor: .marioRed.lighter(by: 0.8)),
        ColorTheme(id: "animalCrossings", mainColor: .animalCrossingsBrown, backgroundColor: .green.lighter(by: 0.6))
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Spacer()

                VStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 40, height: 2)
                        .opacity(0.5)
                        .foregroundColor(Color.primary.opacity(0.4))

                    Text("Themes")
                        .font(.system(.headline, design: .rounded))
                        .bold()
                        .padding(.horizontal, 24)
                }

                Spacer()
            }
            .padding(.top, 6)

            LazyVGrid(
                columns: columns,
                alignment: .center,
                spacing: 20
            ) {
                ForEach(colorThemes, id: \.self) { colorTheme in
                    ColorThemeView(
                        mainColorTemporary: colorTheme.mainColor,
                        backgroundColorTemporary: colorTheme.backgroundColor,
                        themeId: colorTheme.id
                    )
                }
            }
            .padding()

            Spacer()
        }
    }
}

struct ColorTheme: Equatable, Hashable {
    let id: String
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
