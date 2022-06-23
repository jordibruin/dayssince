//
//  CategoryBlocksView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/6/22.
//

import SwiftUI

struct CategoryBlocksView: View {
    
    @Binding var items: [DaysSinceItem]
    @Binding var completedItems: [DaysSinceItem]
    @Binding var favoriteItems: [DaysSinceItem]
    
    
    var body: some View {
        HStack {
            VStack {
                NavigationLink(destination: CategoryFilteredView(category: categoryDaysSinceItem.work, showAddItemSheet: false, editItemSheet: false, items: $items, completedItems: $completedItems, favoriteItems: $favoriteItems))
                {MenuBlockView(category: .work, items: $items, completedItems: $completedItems, favoriteItems: $favoriteItems)}
                
                NavigationLink(destination: CategoryFilteredView(category: categoryDaysSinceItem.life, showAddItemSheet: false, editItemSheet: false, items: $items, completedItems: $completedItems, favoriteItems: $favoriteItems))
                    {MenuBlockView(category: .life, items: $items, completedItems: $completedItems, favoriteItems: $favoriteItems)}
            }
            
            VStack {
                NavigationLink(destination: CategoryFilteredView(category: categoryDaysSinceItem.health, showAddItemSheet: false, editItemSheet: false, items: $items, completedItems: $completedItems, favoriteItems: $favoriteItems))
                {MenuBlockView(category: .health, items: $items, completedItems: $completedItems, favoriteItems: $favoriteItems)}
                NavigationLink(destination: CategoryFilteredView(category: categoryDaysSinceItem.hobbies, showAddItemSheet: false, editItemSheet: false, items: $items, completedItems: $completedItems, favoriteItems: $favoriteItems))
                    {MenuBlockView(category: .hobbies, items: $items, completedItems: $completedItems, favoriteItems: $favoriteItems)}
            }
        }
        .padding(.horizontal)
    }
}


struct CategoryBlocksView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryBlocksView(items: .constant([]), completedItems: .constant([]), favoriteItems: .constant([]))
    }
}
