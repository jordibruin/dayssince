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
    var category: CategoryDaysSinceItem = .work
    
    
    var body: some View {
        if isCategoryView {
            categoryViewList
        } else {
            normalViewList
        }
    }
    
    var categoryViewList: some View {
        ForEach(self.items.filter { $0.category == category } , id: \.id) { item in
            IndividualItemView(
                editItemSheet: $editItemSheet,
                tappedItem: $tappedItem,
                item: item,
                colored: true,
                isFavorite: false
            )
        }
    }
    
    var normalViewList: some View {
        ForEach(self.items, id: \.id) { item in
            IndividualItemView(
                editItemSheet: $editItemSheet,
                tappedItem: $tappedItem,
                item: item,
                colored: false,
                isFavorite: false
            )
        }
    }
}

struct NormalItemsList_Previews: PreviewProvider {
    static var previews: some View {
        NormalItemsList(items: .constant([]), editItemSheet: .constant(false), tappedItem: .constant( .placeholderItem()))
    }
}
