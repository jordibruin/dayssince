//
//  AddItemSheet.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/28/22.
//

import Defaults
import SwiftUI
import UserNotifications

struct AddItemSheet: View {
    @Default(.categories) var categories

    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var notificationManager: NotificationManager

    @State private var name: String = ""
    @State var date: Date = .now
    @State var selectedCategory: Category?
    @State var remindersEnabled: Bool = false
    @State var selectedReminder: DSItemReminders = .daily
    @State var showCategorySheet = false

    @FocusState private var nameIsFocused: Bool

    @Binding var items: [DSItem]

    var accentColor: Color {
        selectedCategory?.color.color ?? .primary
    }

    var body: some View {
        // Form
        NavigationView {
            AddItemForm(items: $items, name: $name, date: $date, category: $selectedCategory, remindersEnabled: $remindersEnabled, showCategorySheet: $showCategorySheet, selectedReminder: $selectedReminder, nameIsFocused: $nameIsFocused)
                .navigationTitle("New Event")
                .navigationBarTitleDisplayMode(.inline)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .toolbar(content: {
                    toolbarItems
                })
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
                .font(.title3)
                .foregroundColor(accentColor)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let newItem = DSItem(
                        id: UUID(),
                        name: name,
                        category: selectedCategory ?? categories.first!,
                        dateLastDone: date,
                        remindersEnabled: remindersEnabled
                    )

                    items.append(newItem)

                    if newItem.remindersEnabled {
                        notificationManager.addReminderFor(item: newItem)
                    }

                    print("➕ Added item. Now there are \(items.count) items!")

                    dismiss()
                } label: {
                    Text("Save")
                }
                .foregroundColor(accentColor)
                .disabled(name.isEmpty)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if nameIsFocused {
                    Button {
                        nameIsFocused = false
                    } label: {
                        Text("Done")
                    }
                    .foregroundColor(accentColor)
                }
            }
        }
    }
}

struct AddItemSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddItemSheet(selectedCategory: Category.placeholderCategory(), items: .constant([]))
    }
}
