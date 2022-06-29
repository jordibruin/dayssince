//
//  EditTappedItemSheet.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/4/22.
//

import SwiftUI

struct EditTappedItemSheet: View {
    @Binding var items: [DaysSinceItem]
    @Binding var completedItems: [DaysSinceItem]
    @Binding var favoriteItems: [DaysSinceItem]
    
    @Binding var tappedItem: DaysSinceItem
    @Binding var editItemSheet: Bool
    
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var nameIsFocused: Bool
    
    
    var body: some View {
        NavigationView {
            ZStack {
                EditTappedItemForm(items: $items, completedItems: $completedItems, favoriteItems: $favoriteItems, tappedItem: $tappedItem, editItemSheet: $editItemSheet, nameIsFocused: $nameIsFocused)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .navigationTitle("Edit Event")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    toolbarItems
                })
                
            }
        }
    }
    
    var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.down.circle.fill")
                }
                .font(.title2)
                .foregroundColor(tappedItem.category.color)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    var item_index = getItemIndex()
                               items[item_index].name = tappedItem.name
                               items[item_index].dateLastDone = tappedItem.dateLastDone
                               items[item_index].category = tappedItem.category
                               editItemSheet = false
                               dismiss()
                } label: {
                    Text("Save")
                }
                .foregroundColor(tappedItem.category.color)
            }
               
            ToolbarItemGroup(placement: .keyboard){
                Button("Done") {
                    nameIsFocused = false
                }
            }
        }
    }
    
    func getItemIndex() -> Int {
        return items.firstIndex(where: {$0.id == tappedItem.id})!
    }
}

struct EditTappedItemSheet_Previews: PreviewProvider {
    static var previews: some View {
        EditTappedItemSheet(items: .constant([]), completedItems: .constant([]), favoriteItems:    .constant([]), tappedItem: .constant(DaysSinceItem.placeholderItem()), editItemSheet: .constant(false))
    }
}