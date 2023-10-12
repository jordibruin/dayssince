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
            .clipShape(Circle())
            .onTapGesture {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()

                withAnimation {
                    mainColor = mainColorTemporary
                    backgroundColor = backgroundColorTemporary
                }
            }
    }
}

struct ColorThemeView_Previews: PreviewProvider {
    static var previews: some View {
        ColorThemeView(mainColorTemporary: Color.workColor, backgroundColorTemporary: Color.backgroundColor)
    }
}
