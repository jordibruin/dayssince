//
//  TopSection.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/23/22.
//

import SwiftUI

struct TopSection: View {
    
    @Binding var items: [DaysSinceItem]
    @Binding var completedItems: [DaysSinceItem]
    @Binding var favoriteItems: [DaysSinceItem]
    
    @Binding var isDaysDisplayModeDetailed: Bool
    
    var body: some View {
        HStack {
            VStack {
                NavigationLink(
                    destination: CategoryFilteredView(
                        category: CategoryDaysSinceItem.work,
                        showAddItemSheet: false,
                        editItemSheet: false,
                        items: $items,
                        completedItems: $completedItems,
                        favoriteItems: $favoriteItems,
                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed)
                ) {
                    MenuBlockView(
                        category: .work,
                        items: $items,
                        completedItems: $completedItems,
                        favoriteItems: $favoriteItems)}
                
                
                NavigationLink(
                    destination: CategoryFilteredView(
                        category: CategoryDaysSinceItem.life,
                        showAddItemSheet: false,
                        editItemSheet: false,
                        items: $items,
                        completedItems: $completedItems,
                        favoriteItems: $favoriteItems,
                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed
                    )
                ) {
                    MenuBlockView(
                        category: .life,
                        items: $items,
                        completedItems: $completedItems,
                        favoriteItems: $favoriteItems
                    )
                }
            }
            
            VStack {
                NavigationLink(
                    destination: CategoryFilteredView(
                        category: CategoryDaysSinceItem.health,
                        showAddItemSheet: false,
                        editItemSheet: false,
                        items: $items,
                        completedItems: $completedItems,
                        favoriteItems: $favoriteItems,
                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed)
                ) {
                    MenuBlockView(
                        category: .health,
                        items: $items,
                        completedItems: $completedItems,
                        favoriteItems: $favoriteItems
                    )
                }
                
                NavigationLink(
                    destination: CategoryFilteredView(
                        category: CategoryDaysSinceItem.hobbies,
                        showAddItemSheet: false,
                        editItemSheet: false,
                        items: $items,
                        completedItems: $completedItems,
                        favoriteItems: $favoriteItems,
                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed)
                ) {
                    MenuBlockView(
                        category: .hobbies,
                        items: $items,
                        completedItems: $completedItems,
                        favoriteItems: $favoriteItems
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}

struct TopSection_Previews: PreviewProvider {
    static var previews: some View {
        TopSection(items: .constant([]), completedItems: .constant([]), favoriteItems: .constant([]), isDaysDisplayModeDetailed: .constant(false))
    }
}
