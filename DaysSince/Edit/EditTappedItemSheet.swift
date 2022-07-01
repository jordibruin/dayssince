//
//  EditTappedItemSheet.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/4/22.
//

import SwiftUI

struct EditTappedItemSheet: View {
    
    @EnvironmentObject var notificationManager: NotificationManager
    
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
                    
                    guard let itemIndex = items.firstIndex(where: {$0.id == tappedItem.id}) else {
                        print("no matching index found")
                        // show an alert to the users
                        return
                    }
                    
//                    var realItem = items[itemIndex]
                    
                    items[itemIndex].name = tappedItem.name
                    items[itemIndex].dateLastDone = tappedItem.dateLastDone
                    items[itemIndex].category = tappedItem.category
                    
                    items[itemIndex].remindersEnabled = tappedItem.remindersEnabled
                    if !items[itemIndex].remindersEnabled {
                        notificationManager.deleteReminderFor(item: items[itemIndex])
                    }
                    
                    if items[itemIndex].reminder != tappedItem.reminder {
                        notificationManager.deleteReminderFor(item: items[itemIndex])
                        items[itemIndex].reminder = tappedItem.reminder
                        notificationManager.addReminderFor(item: items[itemIndex])
                    }
                    editItemSheet = false
                    dismiss()
                } label: {
                    Text("Save")
                }
                .foregroundColor(tappedItem.category.color)
                .disabled(tappedItem.name.isEmpty)
            }
               
            ToolbarItemGroup(placement: .keyboard){
                Button("Done") {
                    nameIsFocused = false
                }
            }
        }
    }
    
    func updateNotificationReminder() {
        let realItem = items[getItemIndex()]
        
        notificationManager.deleteReminderFor(item: realItem)
        notificationManager.addReminderFor(item: realItem)
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
