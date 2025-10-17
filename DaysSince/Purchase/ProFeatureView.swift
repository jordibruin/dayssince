//
//  ProFeatureView.swift
//  DaysSince
//
//  Created by Victoria Petrova on 17/10/2025.
//

import SwiftUI

struct ProFeatureView: View {
    let color: Color
    let emoji: String?
    let symbol: String?
    let featureText: LocalizedStringKey
    
    var body: some View {
        HStack(spacing: 12) {
            symbolOrEmoji()
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .foregroundColor(.white)
                        .frame(width: 48)

                }
                .frame(width: 48)
                
            Text(featureText)
                .font(.system(.title3, design: .rounded))
                .bold()
                .foregroundColor(.white)
            
            Spacer()
            
        }
        .frame(minWidth: 48, minHeight: 48)
        .aspectRatio(1.0, contentMode: .fit)
    }
    
    @ViewBuilder
    func symbolOrEmoji() -> some View {
        if emoji == nil {
            Text(emoji!)
                .font(.system(.title3, design: .rounded))
        } else if symbol != nil {
            Image(systemName: symbol!)
                .foregroundColor(color)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 24, weight: .bold, design: .rounded))
        } else {
            Image(systemName: "checkmark.square.fill")
        }
    }
}

#Preview {
    ProFeatureView(color: .red, emoji: "😀", symbol: nil, featureText: "This is a feature")
}
