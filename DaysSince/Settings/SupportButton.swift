//
//  SupportButton.swift
//  DaysSince
//
//  Created by Vicki Minerva on 6/30/22.
//

import Defaults
import SwiftUI

struct SupportButton: View {
    @Default(.mainColor) var mainColor

    var body: some View {
        NavigationLink {
            SupportScreen()
                .interactiveDismissDisabled()
        } label: {
            HStack {
                LinearGradient(colors: [mainColor, mainColor.lighter()], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: 34, height: 34)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "questionmark")
                            .foregroundColor(.white)
                            .bold()
                    )
                    .padding(.leading, -10)

                text
            }
        }
    }

    var text: some View {
        Text("Support")
            .font(.system(.body, design: .rounded))
    }
}

struct SupportButton_Previews: PreviewProvider {
    static var previews: some View {
        SupportButton()
    }
}
