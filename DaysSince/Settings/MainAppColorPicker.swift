//
//  MainAppColorPicker.swift
//  DaysSince
//
//  Created by Vicki Minerva on 9/24/23.
//

import Defaults
import SwiftUI

struct MainAppColorPicker: View {
    @Default(.mainColor) var mainColor

    var body: some View {
        Section {
            HStack {
                buttonImage
                buttonText
                Spacer()
                colorPicker
            }
        }
    }

    var buttonImage: some View {
        LinearGradient(colors: [Color.workColor, Color.workColor.lighter()], startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(width: 30, height: 30)
            .cornerRadius(8)
            .overlay(
                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.white)
            )
            .padding(.leading, -10)
    }

    var buttonText: some View {
        Text("Customize the color of the app")
            .font(.system(.body, design: .rounded))
    }

    var colorPicker: some View {
        ColorPicker("Set the main app color", selection: $mainColor)
            .labelsHidden()
    }
}

struct MainAppColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        MainAppColorPicker()
    }
}
