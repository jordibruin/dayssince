//
//  BottomSection.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/23/22.
//

import SwiftUI

struct BottomSection: View {
    @Binding var items: [DaysSinceItem]
    @Binding var completedItems: [DaysSinceItem]
    @Binding var favoriteItems: [DaysSinceItem]
    
    @Binding var editItemSheet: Bool
    @Binding var tappedItem: DaysSinceItem
    
    
    var body: some View {
        Section {
            Spacer()
            
            FavoriteItemsList(favoriteItems: $favoriteItems, editItemSheet: $editItemSheet, tappedItem: $tappedItem)
            NormalItemsList(items: $items, editItemSheet: $editItemSheet, tappedItem: $tappedItem)

            Divider()
            
            CompletedItemsList(completedItems: $completedItems)
            
            // Add some space after the items for the button.
            Color(.clear)
                .frame(height: 100)
                
        }
        .padding(.vertical,1)
    }
}

struct BottomSection_Previews: PreviewProvider {
    static var previews: some View {
        BottomSection(items: .constant([.placeholderItem()]), completedItems: .constant([.placeholderItem()]), favoriteItems: .constant([.placeholderItem()]), editItemSheet: .constant(false), tappedItem: .constant(DaysSinceItem.placeholderItem()))
    }
}
