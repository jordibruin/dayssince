//
//  CategoryBlocksView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/6/22.
//

import SwiftUI

struct CategoryBlocksView: View {
    @Binding var items: [DaysSinceItem]
    var body: some View {
        HStack {
            VStack {
                NavigationLink(destination: CategoryFilteredView(color: colorDaysSinceItem.work, categoryName: "Work", emoji: "workCategoryIcon", items: $items, showAddItemSheet: false, editItemSheet: false)) {MenuBlockView(color: Color.workColor, categoryName: "Work", emoji: "workCategoryIcon", items: $items)}
                
                NavigationLink(destination: CategoryFilteredView(color: colorDaysSinceItem.life, categoryName: "Life", emoji: "lifeCategoryIcon", items: $items, showAddItemSheet: false, editItemSheet: false)) {MenuBlockView(color: Color.lifeColor, categoryName: "Life", emoji: "lifeCategoryIcon", items: $items)}
            }
            
            VStack {
                NavigationLink(destination: CategoryFilteredView(color:colorDaysSinceItem.health, categoryName: "Health", emoji: "healthCategoryIcon", items: $items, showAddItemSheet: false, editItemSheet: false)) {MenuBlockView(color: Color.healthColor, categoryName: "Health", emoji: "healthCategoryIcon", items: $items)}
                NavigationLink(destination: CategoryFilteredView(color: colorDaysSinceItem.hobbies, categoryName: "Hobbies", emoji: "hobbiesCategoryIcon", items: $items, showAddItemSheet: false, editItemSheet: false)) {MenuBlockView(color: Color.hobbiesColor, categoryName: "Hobbies", emoji: "hobbiesCategoryIcon", items: $items)}
            }
        }
        .padding(.horizontal)
    }
}

struct MenuBlockView: View {
    
//    init(color: Color = .red, categoryName: String = "Category", emoji: String = "icons8-flag-in-hole-48", items: [DaysSinceItem] = []) {
////        self.items = items
//        self.color = color
//        self.categoryName = categoryName
//        self.emoji = emoji
//        self.items = items
//    }
    
    let color: Color
    let categoryName: String
    let emoji: String
    @Binding var items: [DaysSinceItem]
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(LinearGradient(
                    gradient: .init(colors: [color.opacity(0.7), color]),
                    startPoint: .init(x: 0.0, y: 0),
                  endPoint: .init(x: 0.9, y: 0.8)
                ))
            
            
            VStack(alignment: .leading, spacing: 0) {
                Image(emoji)
                    .font(.largeTitle)
                
                Text(categoryName)
                    .font(.system(.title3, design: .rounded))
                    .bold()
             // This could be problematic in the future. Better add a category property in the DaysSinceItem struct and count according to that instead of the color.
                Text("\(items.filter{ $0.color.color == color}.count) events")
            }
            .padding(12)
        }
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(color: color, radius: 10, x: 0, y: 5)
    }
}

struct CategoryBlocksView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryBlocksView(items: .constant([]))
    }
}
