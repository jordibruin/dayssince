//
//  DetailedTimeDisplayMode.swift
//  DaysSince
//
//  Created by Vicki Minerva on 7/26/22.
//

import Defaults
import SwiftUI

struct DetailedTimeDisplayModeCell: View {
    @Binding var isDaysDisplayModeDetailed: Bool

    @Default(.mainColor) var mainColor

    var body: some View {
        Section {
            HStack {
                buttonImage
                buttonText
                Spacer()
                toggle
            }
        } footer: {
            Text("Display the number of years, months, and days since an event")
                .font(Font.system(.body, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, -8)
        }
    }

    var buttonImage: some View {
        LinearGradient(colors: [mainColor, mainColor.lighter()], startPoint: .topLeading, endPoint: .bottomTrailing)
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
        // TODO: Current wording is poor.
        Text("Detailed Time Display Mode")
            .font(.system(.body, design: .rounded))
    }

    var toggle: some View {
        Toggle("Detailed Time Display Mode", isOn: $isDaysDisplayModeDetailed)
            .tint(mainColor)
            .labelsHidden()
            .onChange(of: isDaysDisplayModeDetailed) { isDaysDisplayModeDetailed in
                if isDaysDisplayModeDetailed {
                    Analytics.send(.detailedModeOn)
                }
            }
                
    }
}

struct DetailedTimeDisplayMode_Previews: PreviewProvider {
    static var previews: some View {
        DetailedTimeDisplayModeCell(isDaysDisplayModeDetailed: .constant(false))
    }
}
