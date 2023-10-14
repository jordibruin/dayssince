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
        VStack {
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
                .overlay((colorEquals("Main", mainColorTemporary, mainColor) || colorEquals("Background", backgroundColorTemporary, backgroundColor)) ? .clear : Color.black.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .onTapGesture {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()

                    mainColor = mainColorTemporary

                    backgroundColor = backgroundColorTemporary
                }
        }
    }

    func colorEquals(_ x: String, _ color1: Color, _ color2: Color) -> Bool {
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
