//
//  ColorThemeView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 9/24/23.
//

import Defaults
import SwiftUI

struct ColorThemeView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var reviewManager: ReviewManager

    @Default(.mainColor) var mainColor
    @Default(.backgroundColor) var backgroundColor
    @Default(.selectedThemeId) var selectedThemeId

    let mainColorTemporary: Color
    let backgroundColorTemporary: Color
    let themeId: String

    var isThemeSelected: Bool {
        return themeId == selectedThemeId
    }
    
    var body: some View {
        Circle()
            .frame(width: 72, height: 72)
            .overlay {
                LinearGradient(stops: [
                    Gradient.Stop(color: backgroundColorTemporary, location: 0),
                    Gradient.Stop(color: backgroundColorTemporary, location: 0.5),
                    Gradient.Stop(color: mainColorTemporary, location: 0.5),
                    Gradient.Stop(color: mainColorTemporary, location: 1),
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(colorScheme == .light ? .black : .white, lineWidth: isThemeSelected ? 6 : 0)
                    .background(isThemeSelected ? .clear : .black.opacity(0.5))
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .onTapGesture {
                Analytics.send(.chooseTheme, with: ["themeId": themeId])
                
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()

                withAnimation {
                    selectedThemeId = themeId
                    mainColor = mainColorTemporary
                    backgroundColor = backgroundColorTemporary
                }
                
                reviewManager.promptReviewAlert()
            }
            .transition(.opacity)
    }

    // MARK: - Actions

    func colorEquals(_ color1: Color, _ color2: Color) -> Bool {
        let uiColor1 = UIColor(color1)
        let uiColor2 = UIColor(color2)

        return uiColor1 == uiColor2
    }
}

struct ColorThemeView_Previews: PreviewProvider {
    static var previews: some View {
        ColorThemeView(mainColorTemporary: Color.workColor, backgroundColorTemporary: Color.backgroundColor, themeId: "default")
        ColorThemeView(mainColorTemporary: Color.workColor, backgroundColorTemporary: Color.backgroundColor, themeId: "default")
    }
}
