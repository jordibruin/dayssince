//
//  WishKitView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 12/2/23.
//

import Defaults
import SwiftUI
import WishKit

struct WishKitView: View {
    @Default(.mainColor) var mainColor

    var body: some View {
        NavigationLink {
            WishKit.view
        } label: {
            HStack {
                LinearGradient(colors: [mainColor, mainColor.lighter()], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: 34, height: 34)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.white)
                    )
                    .padding(.leading, -10)

                text
            }
        }
    }

    var text: some View {
        Text("Suggest Features")
            .font(.system(.body, design: .rounded))
    }
}

struct WishKitView_Previews: PreviewProvider {
    static var previews: some View {
        WishKitView()
    }
}
