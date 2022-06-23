//
//  NormalItemsList.swift
//  DaysSince
//
//  Created by Vicki Minerva on 6/3/22.
//

import SwiftUI


struct NormalItemsList: View {
    @Binding var items: [DaysSinceItem]
    @Binding var editItemSheet: Bool
    @Binding var tappedItem: DaysSinceItem
    
    var isCategoryView: Bool = false
    var category: categoryDaysSinceItem = .work
    
    
    var body: some View {
        if isCategoryView {
            ForEach(self.items, id: \.id) { item in
                if item.category == category {
                    IndividualItemView(item: item, editItemSheet: $editItemSheet, tappedItem: $tappedItem, colored: true, isFavorite: false)

                }
            }
        } else {
            ForEach(self.items, id: \.id) { item in
                IndividualItemView(item: item, editItemSheet: $editItemSheet, tappedItem: $tappedItem, colored: false, isFavorite: false)
            }
        }
    }
}

struct NormalItemsList_Previews: PreviewProvider {
    static var previews: some View {
        NormalItemsList(items: .constant([]), editItemSheet: .constant(false), tappedItem: .constant( .placeholderItem()))
    }
}
