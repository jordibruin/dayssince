//
//  EditTappedItemSheet.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/4/22.
//

import SwiftUI

struct EditTappedItemSheet: View {
    @EnvironmentObject var notificationManager: NotificationManager

    @Binding var items: [DSItem]
    @Binding var editItemSheet: Bool
    @Binding var tappedItem: DSItem

    @Environment(\.dismiss) var dismiss

    @FocusState private var nameIsFocused: Bool
    @State var showCategorySheet = false

    var body: some View {
        NavigationView {
            ZStack {
                EditTappedItemForm(
                    items: $items,
                    editItemSheet: $editItemSheet,
                    tappedItem: $tappedItem,
                    showCategorySheet: $showCategorySheet,
                    nameIsFocused: $nameIsFocused
                )
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .navigationTitle("Edit Event")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    toolbarItems
                })
            }
        }
        .sheet(isPresented: $showCategorySheet) {
            AddCategorySheet()
                .presentationDragIndicator(.hidden)
                .presentationDetents([.medium])
                .presentationCornerRadius(44)
                .onDisappear { showCategorySheet = false }
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
                .foregroundColor(tappedItem.category.color.color)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    guard let itemIndex = items.firstIndex(where: { $0.id == tappedItem.id }) else {
                        print("no matching index found")
                        // show an alert to the users
                        return
                    }

//                    var realItem = items[itemIndex]

                    items[itemIndex].name = tappedItem.name
                    items[itemIndex].dateLastDone = tappedItem.dateLastDone
                    items[itemIndex].category = tappedItem.category

                    items[itemIndex].remindersEnabled = tappedItem.remindersEnabled

                    // IF reminders are disabled, remove all future notifications.
                    if !items[itemIndex].remindersEnabled {
                        notificationManager.deleteReminderFor(item: items[itemIndex])
                    } else {
                        // If the user changed the frequency update the trigger.
//                        if items[itemIndex].reminder != tappedItem.reminder {
//                            notificationManager.deleteReminderFor(item: items[itemIndex])
//                            items[itemIndex].reminder = tappedItem.reminder
//                            notificationManager.addReminderFor(item: items[itemIndex])
//                        }
                        notificationManager.deleteReminderFor(item: items[itemIndex])
                        items[itemIndex].reminder = tappedItem.reminder
                        notificationManager.addReminderFor(item: items[itemIndex])
                    }

                    editItemSheet = false
                    dismiss()
                } label: {
                    Text("Save")
                }
                .foregroundColor(tappedItem.name.isEmpty ? Color.gray : tappedItem.category.color.color)
                .disabled(tappedItem.name.isEmpty)
            }

            // Add a button to close the keyboard
            ToolbarItem(placement: .navigationBarTrailing) {
                if nameIsFocused {
                    Button {
                        withAnimation {
                            nameIsFocused = false
                        }

                    } label: {
                        Text("Done")
                    }
                    .foregroundColor(tappedItem.category.color.color)
                }
            }
        }
    }

    // MARK: - Actions

    func updateNotificationReminder() {
        let realItem = items[getItemIndex()]

        notificationManager.deleteReminderFor(item: realItem)
        notificationManager.addReminderFor(item: realItem)
    }

    func getItemIndex() -> Int {
        return items.firstIndex(where: { $0.id == tappedItem.id })!
    }
}

struct EditTappedItemSheet_Previews: PreviewProvider {
    static var previews: some View {
        EditTappedItemSheet(items: .constant([]),
                            editItemSheet: .constant(false),
                            tappedItem: .constant(DSItem.placeholderItem()))
    }
}
