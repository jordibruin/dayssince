//
//  CustomButton.swift
//  DaysSince
//
//  Created by Victoria Petrova on 03/05/2025.
//

import SwiftUI

struct CustomButton: View {
    var action: () -> Void
    var label: String
    var color: Color = Color.workColor
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(label)
                    .font(.system(.title, design: .default))
                    .bold()
                    .foregroundColor(.white)
                Spacer()
            }
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding()
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 32)
    }
}

#Preview {
    CustomButton(action: { print("hi")}, label: "Next", color: .workColor)
}
