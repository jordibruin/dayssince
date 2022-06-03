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
                
                Spacer()
                VStack {
                    Spacer()
                    
                    saveButton
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                toolbarItems
            })
        }
    }
    
    var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "x.square")
                }
                .font(.title2)
                .foregroundColor(tappedItem.category.color)
            }
               
            ToolbarItem(placement: .principal) { // <3>
                Text("\(tappedItem.name)")
                    .font(.system(.largeTitle, design: .rounded))
                    .bold()
                    .accessibilityAddTraits(.isHeader)
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
    
    var saveButton: some View {
        Button {
            var item_index = getItemIndex()
            items[item_index].name = tappedItem.name
            /// FIX
//            items[item_index].emoji = tappedItem.emoji
            items[item_index].dateLastDone = tappedItem.dateLastDone
            items[item_index].category = tappedItem.category
            editItemSheet = false
            dismiss()
        } label: {
            Text("Save")
                .font(.system(.title, design: .rounded))
                .bold()
                .foregroundColor(.white)
        }
        .padding()
        .background(LinearGradient(
            gradient: .init(colors: [tappedItem.category.color.opacity(0.8), tappedItem.category.color]),
            startPoint: .init(x: 0.0, y: 0.5),
            endPoint: .init(x: 0, y: 1)))
        .clipShape(Capsule())
        .shadow(color: tappedItem.category.color, radius: 10, x: 0, y: 5)
    }
}

struct EditTappedItemSheet_Previews: PreviewProvider {
    static var previews: some View {
        EditTappedItemSheet(items: .constant([]), completedItems: .constant([]), favoriteItems:    .constant([]), tappedItem: .constant(DaysSinceItem.placeholderItem()), editItemSheet: .constant(false))
    }
}
