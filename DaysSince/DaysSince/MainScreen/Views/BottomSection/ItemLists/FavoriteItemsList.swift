//
//  FavoriteItemsList.swift
//  DaysSince
//
//  Created by Vicki Minerva on 6/3/22.
//

import SwiftUI


struct FavoriteItemsList: View {
    
    @Binding var favoriteItems: [DaysSinceItem]
    @Binding var editItemSheet: Bool
    @Binding var tappedItem: DaysSinceItem
    
    var isCategoryView: Bool = false
    
    var category: CategoryDaysSinceItem = .work
    
    
    var body: some View {
        if isCategoryView {
            ForEach(self.favoriteItems, id: \.id) { item in
                if item.category == category {
                    IndividualItemView(item: item, editItemSheet: $editItemSheet, tappedItem: $tappedItem, colored: true, isFavorite: true)

                }
            }
        } else {
            ForEach(self.favoriteItems, id: \.id) { item in
                IndividualItemView(item: item, editItemSheet: $editItemSheet, tappedItem: $tappedItem, colored: false, isFavorite: true)
            }
        }
    }
}

struct FavoriteItemsList_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteItemsList(favoriteItems: .constant([]), editItemSheet: .constant(false), tappedItem: .constant(DaysSinceItem.placeholderItem()))
    }
}
