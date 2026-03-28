//
//  BottomSection.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/23/22.
//

import Defaults
import SwiftUI

struct BottomSection: View {
    @Default(.categories) var categories

    @Binding var items: [DSItem]

    @Binding var editItemSheet: Bool
    @Binding var tappedItem: DSItem
    @Binding var isDaysDisplayModeDetailed: Bool
    @Binding var showPaywall: Bool

    var body: some View {
        DSItemListView(
            items: $items,
            editItemSheet: $editItemSheet,
            tappedItem: $tappedItem,
            isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed,
            showPaywall: $showPaywall
        )

        // Add some space after the items for the button.
        Color(.clear)
            .frame(height: 100)
            .padding(.vertical, 1)
    }
}

struct BottomSection_Previews: PreviewProvider {
    static var previews: some View {
        BottomSection(items: .constant([.placeholderItem()]),
                      editItemSheet: .constant(false),
                      tappedItem: .constant(DSItem.placeholderItem()),
                      isDaysDisplayModeDetailed: .constant(false),
                      showPaywall: .constant(false))
    }
}
