//
//  MenuBlockView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/25/22.
//

import SwiftUI

struct MenuBlockView: View {
    
    let category: CategoryDaysSinceItem
    
    @Binding var items: [DaysSinceItem]
    @Binding var completedItems: [DaysSinceItem]
    @Binding var favoriteItems: [DaysSinceItem]
    
    var body: some View {
        ZStack(alignment: .leading) {
            colorShape
            content
        }
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: category.color.opacity(0.4), radius: 5, x: 0, y: 5)
    }
    
    var colorShape: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: .init(
                        colors: [
                            category.color.opacity(0.7),
                            category.color
                        ]
                    ),
                    startPoint: .init(x: 0.0, y: 0),
                    endPoint: .init(x: 0.9, y: 0.8)
                )
            )
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            emoji
            nameText
            itemCount
        }
        .padding(12)
    }
    
    var emoji: some View {
        Image(category.emoji)
            .resizable()
            .frame(width: 36, height: 36)
    }
    
    var nameText: some View {
        Text(category.name)
            .font(.system(.title3, design: .rounded))
            .bold()
    }
    
    var itemCount: some View {
        Text("\(findItemCount()) events")
    }
    
    func findItemCount() -> Int {
        return items.filter{ $0.category == category}.count + completedItems.filter{ $0.category == category}.count + favoriteItems.filter{ $0.category == category}.count
        
    }
}


struct MenuBlockView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBlockView(category: .work, items: .constant([]), completedItems: .constant([]), favoriteItems: .constant([]))
    }
}
