//
//  SettingsReviewButton.swift
//  DaysSince
//
//  Created by Vicki Minerva on 6/30/22.
//

import SwiftUI

struct SettingsReviewButton: View {
    
    
    var body: some View {
        
        Button {
            print("Open review link")
        } label: {
            HStack {
                LinearGradient(colors: [Color.workColor, Color.workColor.lighter()], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: 34, height: 34)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "star.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.white)
                    )
                    .padding(.leading, -10)
                
                text
                    
                Spacer()
                Image(systemName: "arrow.up.forward.app.fill")
                    .font(.title2)
                    .foregroundColor(Color.white)
                    .opacity(0.5)
            }
        }
        .foregroundColor(.primary)
    }
    
    var text: some View {
        Text("Review Days Since")
            .font(.system(.body, design: .rounded))
    }
}

struct SettingsReviewButton_Previews: PreviewProvider {
    static var previews: some View {
        SettingsReviewButton()
    }
}
