//
//  CategorySelectionView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/11/22.
//

import SwiftUI

struct CategorySelectionView: View {
    init(color: Color = .red, name: String = "Category", emoji: String = "description") {
        self.color = color
        self.name = name
        self.emoji = emoji
    }
    
    let color: Color
    let name: String
    let emoji: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            color
             
            VStack(alignment: .center) {
                Image(emoji)
//                    .font(.system(.title3, design: .rounded))
//                    .bold()
                    
                Text(name)
                    .font(.system(.title2, design: .rounded))
                    .bold()
            }
            .foregroundColor(.white)
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .shadow(color: color, radius: 10, x: 0, y: 5)
    }
}

struct CategorySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CategorySelectionView()
    }
}


