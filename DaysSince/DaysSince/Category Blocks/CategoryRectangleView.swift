//
//  CategoryView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/11/22.
//

import SwiftUI

struct CategoryRectangleView: View {
//    init(category: CategoryDaysSinceItem = CategoryDaysSinceItem.health, selectedCategory: CategoryDaysSinceItem? = CategoryDaysSinceItem.hobbies) {
//        self.category = category
//        self.selectedCategory = selectedCategory
//    }
    
    var category: CategoryDSItem
    
    var selectedCategory: CategoryDSItem?
    
    var body: some View {
        ZStack(alignment: .leading) {
            backgroundColor
            categoryBlockContent
        }
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .shadow(color: selectedCategory == nil ? category.color : selectedCategory == category ? category.color : category.color.opacity(0.2) , radius: 10, x: 0, y: 5)
    }
    
    var backgroundColor: some View {
        withAnimation {
            category.color
                .opacity(selectedCategory == nil ? 1 : selectedCategory == category ? 1 : 0.7)
        }
    }
    
    var categoryBlockContent: some View {
        VStack(alignment: .center) {
            emoji
            titleText
        }
        .foregroundColor(.white)
        .padding()
    }
    
    @ViewBuilder
    var emoji: some View {
        Image(category.emoji)
    }
    
    var titleText: some View {
        Text(category.name)
            .font(.system(.title2, design: .rounded))
            .bold()
    }
}

struct CategoryRectangleView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryRectangleView(category: .health, selectedCategory: nil)
    }
}


