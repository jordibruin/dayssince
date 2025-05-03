//
//  ProgressBar.swift
//  DaysSince
//
//  Created by Victoria Petrova on 04/05/2025.
//

import Foundation
import SwiftUI

struct ProgressBar: View {
    var progress: CGFloat // between 0.0 and 1.0
    var height: CGFloat = 8
    var cornerRadius: CGFloat = 4
    var accentColor: Color = .animalCrossingsGreen

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemGray5))
                    .frame(height: height)

                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(accentColor)
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(.easeOut(duration: 0.25), value: progress)
            }
        }
        .frame(height: height)
    }
}
