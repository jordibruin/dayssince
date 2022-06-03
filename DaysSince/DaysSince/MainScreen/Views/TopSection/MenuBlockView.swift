//
//  MenuBlockView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/25/22.
//

import SwiftUI

struct MenuBlockView: View {
    
//    init(color: Color = .red, categoryName: String = "Category", emoji: String = "icons8-flag-in-hole-48", items: [DaysSinceItem] = []) {
////        self.items = items
//        self.color = color
//        self.categoryName = categoryName
//        self.emoji = emoji
//        self.items = items
//    }
    
    let category: categoryDaysSinceItem
    
    @Binding var items: [DaysSinceItem]
    @Binding var completedItems: [DaysSinceItem]
    @Binding var favoriteItems: [DaysSinceItem]
    
    
    var body: some View {
        ZStack(alignment: .leading) {
            colorShape
            content
        }
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(color: category.color, radius: 10, x: 0, y: 5)
    }
    
    var colorShape: some View {
        Rectangle()
            .fill(LinearGradient(
                gradient: .init(colors: [category.color.opacity(0.7), category.color]),
                startPoint: .init(x: 0.0, y: 0),
              endPoint: .init(x: 0.9, y: 0.8)
            ))
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
            .font(.largeTitle)
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
