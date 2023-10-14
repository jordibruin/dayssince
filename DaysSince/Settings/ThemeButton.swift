//
//  ThemeButton.swift
//  DaysSince
//
//  Created by Vicki Minerva on 9/24/23.
//

import Defaults
import SwiftUI

struct ThemeButton: View {
    @Default(.mainColor) var mainColor
    @Binding var showSettings: Bool
    @Binding var showThemeSheet: Bool

    var body: some View {
        Button {
            showSettings = false
            showThemeSheet = true
        } label: {
            HStack {
                buttonImage
                buttonText
                Spacer()
                Image(systemName: "chevron.right")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.gray)
            }
        }
        .foregroundColor(.primary)
    }

    var buttonImage: some View {
        LinearGradient(colors: [mainColor, mainColor.lighter()], startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(width: 30, height: 30)
            .cornerRadius(8)
            .overlay(
                Image(systemName: "paintpalette.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.white)
            )
            .padding(.leading, -10)
    }

    var buttonText: some View {
        Text("Customize theme")
            .font(.system(.body, design: .rounded))
    }
}

struct MainAppColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        ThemeButton(showSettings: .constant(true), showThemeSheet: .constant(false))
    }
}
