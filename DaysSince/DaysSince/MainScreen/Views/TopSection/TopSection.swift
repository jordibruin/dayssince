//
//  TopSection.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/23/22.
//

import SwiftUI

/**
 The top section of the main screen contains the grid with the categories for the events.
 By clicking on any of the categories it will lead you to a filtered view with events only from that category.
 */
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
                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed
                    )
                ) {
                    MenuBlockView(
                        category: .work,
                        items: $items
                    )
                }

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
                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed
                    )
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
                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed
                    )
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
