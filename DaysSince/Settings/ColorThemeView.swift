//
//  ColorThemeView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 9/24/23.
//

import Defaults
import SwiftUI

struct ColorThemeView: View {
    @Default(.mainColor) var mainColor
    @Default(.backgroundColor) var backgroundColor

    let mainColorTemporary: Color
    let backgroundColorTemporary: Color

    var body: some View {
        let isThemeSelected = (colorEquals(mainColorTemporary, mainColor) || colorEquals(backgroundColorTemporary, backgroundColor))

        Circle()
            .frame(width: 72, height: 72)
            .overlay {
                LinearGradient(stops: [
                    Gradient.Stop(color: mainColorTemporary, location: 0),
                    Gradient.Stop(color: mainColorTemporary, location: 0.5),
                    Gradient.Stop(color: backgroundColorTemporary, location: 0.5),
                    Gradient.Stop(color: backgroundColorTemporary, location: 1),
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.black, lineWidth: isThemeSelected ? 6 : 0)
                    .background(isThemeSelected ? .clear : .black.opacity(0.2))
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .onTapGesture {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()

                withAnimation {
                    mainColor = mainColorTemporary
                    backgroundColor = backgroundColorTemporary
                }
            }
            .transition(.opacity)
    }

    func colorEquals(_ color1: Color, _ color2: Color) -> Bool {
        let uiColor1 = UIColor(color1)
        let uiColor2 = UIColor(color2)

        return uiColor1 == uiColor2
    }
}

struct ColorThemeView_Previews: PreviewProvider {
    static var previews: some View {
        ColorThemeView(mainColorTemporary: Color.workColor, backgroundColorTemporary: Color.backgroundColor)
        ColorThemeView(mainColorTemporary: Color.workColor, backgroundColorTemporary: Color.backgroundColor)
    }
}
