//
//  CompletedItemsList.swift
//  DaysSince
//
//  Created by Vicki Minerva on 6/3/22.
//

import SwiftUI




struct CompletedItemsList: View {
    @Binding var completedItems: [DaysSinceItem]
    
    var isCategoryView: Bool = false
    var category: CategoryDaysSinceItem = .work
    
    
    var body: some View {
        if isCategoryView {
            ForEach(self.completedItems, id: \.id) { item in
                if item.category == category {
                    CompletedIndividualItem(item: item)

                }
            }
        } else {
            ForEach(self.completedItems, id: \.id) { item in
                CompletedIndividualItem(item: item)
            }
        }
    }
}

struct CompletedItemsList_Previews: PreviewProvider {
    static var previews: some View {
        CompletedItemsList(completedItems: .constant([.placeholderItem(), .placeholderItem()]))
    }
}
