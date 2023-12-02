//
//  DSItemListView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 6/3/22.
//

import SwiftUI

struct DSItemListView: View {
    @Binding var items: [DSItem]
    @Binding var editItemSheet: Bool
    @Binding var tappedItem: DSItem
    @Binding var isDaysDisplayModeDetailed: Bool

    var isCategoryView: Bool = false
    var category: Category?

    var body: some View {
        if isCategoryView {
            categorizedItemListView
        } else {
            itemListView
        }
    }

    var categorizedItemListView: some View {
        ForEach(self.items.filter { $0.category == category }, id: \.id) { item in
            DSItemView(
                editItemSheet: $editItemSheet,
                tappedItem: $tappedItem,
                isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed,
                item: item,
                colored: true
            )
        }
    }

    @AppStorage("selectedSortType") var selectedSortType: SortType = .daysAscending

    var itemListView: some View {
        ForEach(self.items.sorted { selectedSortType.sort(itemOne: $0, itemTwo: $1) }) { item in

            DSItemView(
                editItemSheet: $editItemSheet,
                tappedItem: $tappedItem,
                isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed,
                item: item,
                colored: false
            )
        }
    }
}

struct NormalItemsList_Previews: PreviewProvider {
    static var previews: some View {
        DSItemListView(items: .constant([]), editItemSheet: .constant(false), tappedItem: .constant(.placeholderItem()), isDaysDisplayModeDetailed: .constant(false), category: Category.placeholderCategory())
    }
}
