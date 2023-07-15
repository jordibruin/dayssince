//
//  TopSection.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/23/22.
//

import SwiftUI

struct TopSection: View {
    
    @Binding var items: [DSItem]
    
    @Binding var isDaysDisplayModeDetailed: Bool
    
    var body: some View {
        HStack {
            VStack {
                NavigationLink(
                    destination: CategoryFilteredView(
                        category: CategoryDSItem.work,
                        showAddItemSheet: false,
                        editItemSheet: false,
                        items: $items,
                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed)
                ) {
                    MenuBlockView(
                        category: .work,
                        items: $items)}
                
                
                NavigationLink(
                    destination: CategoryFilteredView(
                        category: CategoryDSItem.life,
                        showAddItemSheet: false,
                        editItemSheet: false,
                        items: $items,
                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed
                    )
                ) {
                    MenuBlockView(
                        category: .life,
                        items: $items
                    )
                }
            }
            
            VStack {
                NavigationLink(
                    destination: CategoryFilteredView(
                        category: CategoryDSItem.health,
                        showAddItemSheet: false,
                        editItemSheet: false,
                        items: $items,
                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed)
                ) {
                    MenuBlockView(
                        category: .health,
                        items: $items
                    )
                }
                
                NavigationLink(
                    destination: CategoryFilteredView(
                        category: CategoryDSItem.hobbies,
                        showAddItemSheet: false,
                        editItemSheet: false,
                        items: $items,
                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed)
                ) {
                    MenuBlockView(
                        category: .hobbies,
                        items: $items
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}

struct TopSection_Previews: PreviewProvider {
    static var previews: some View {
        TopSection(items: .constant([]), isDaysDisplayModeDetailed: .constant(false))
    }
}
