//
//  TopSection.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/23/22.
//

import Defaults
import SwiftUI

/**
 The top section of the main screen contains the grid with the categories for the events.
 By clicking on any of the categories it will lead you to a filtered view with events only from that category.
 */
struct TopSection: View {
    @Default(.categories) var categories

    @Binding var items: [DSItem]
    @Binding var isDaysDisplayModeDetailed: Bool

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(categories, id: \.id) { category in
                    NavigationLink(
                        destination: CategoryFilteredView(
                            category: category,
                            showAddItemSheet: false,
                            editItemSheet: false,
                            items: $items,
                            isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed
                        )
                    ) {
                        MenuBlockView(
                            category: category,
                            items: $items
                        )
                        .aspectRatio(1.0, contentMode: .fit) // Maintain square aspect ratio
                        .frame(minWidth: 0, maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 16) // Adjust horizontal padding as needed
            .padding(.vertical, 16) // Adjust vertical padding as needed
        }
        .padding(.leading, 16)
//
//
//                NavigationLink(
//                    destination: CategoryFilteredView(
//                        category: CategoryDSItem.life,
//                        showAddItemSheet: false,
//                        editItemSheet: false,
//                        items: $items,
//                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed
//                    )
//                ) {
//                    MenuBlockView(
//                        category: .life,
//                        items: $items
//                    )
//                }
//            }
//
//            VStack {
//                NavigationLink(
//                    destination: CategoryFilteredView(
//                        category: CategoryDSItem.health,
//                        showAddItemSheet: false,
//                        editItemSheet: false,
//                        items: $items,
//                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed
//                    )
//                ) {
//                    MenuBlockView(
//                        category: .health,
//                        items: $items
//                    )
//                }
//
//                NavigationLink(
//                    destination: CategoryFilteredView(
//                        category: CategoryDSItem.hobbies,
//                        showAddItemSheet: false,
//                        editItemSheet: false,
//                        items: $items,
//                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed
//                    )
//                ) {
//                    MenuBlockView(
//                        category: .hobbies,
//                        items: $items
//                    )
//                }
    }
}

struct TopSection_Previews: PreviewProvider {
    static var previews: some View {
        TopSection(items: .constant([]), isDaysDisplayModeDetailed: .constant(false))
    }
}
