//
//  AddItemSheet.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/28/22.
//

import SwiftUI
import UserNotifications


struct AddItemSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var name: String = ""
    @State var date: Date = Date.now
    @State var selectedCategory: CategoryDSItem? = nil
    @State var remindersEnabled: Bool = false
    @State var selectedReminder: DSItemReminders = .daily
    
    @FocusState private var nameIsFocused: Bool
    
    @Binding var items: [DSItem]
    
    var accentColor: Color {
        selectedCategory == nil ? Color.black : selectedCategory?.color as! Color
    }

    var body: some View {
                    
        // Form
        NavigationView {
            AddItemForm(items: $items, name: $name, date: $date, category: $selectedCategory, remindersEnabled: $remindersEnabled, selectedReminder: $selectedReminder, nameIsFocused: $nameIsFocused)
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .toolbar(content: {
                toolbarItems
            })
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
                .foregroundColor(self.selectedCategory != nil ? self.selectedCategory!.color : .primary)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let newItem = DSItem(
                        id: UUID(),
                        name: name,
                        category: selectedCategory ?? .life,
                        dateLastDone: date,
                        remindersEnabled: remindersEnabled
                    )
                    
                    items.append(newItem)
                        
                    if newItem.remindersEnabled {
                        notificationManager.addReminderFor(item: newItem)
                    }
                    
                    
                    print("➕ Added item. Now there are \(items.count) items!")
                    
                    if let itemAdded = items.last {
                    }
                    dismiss()
                } label: {
                    Text("Save")
                }
                .foregroundColor(name.isEmpty ? Color.gray : self.selectedCategory != nil ? self.selectedCategory!.color : .primary)
                .disabled(name.isEmpty)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if nameIsFocused {
                    Button {
                        nameIsFocused = false
                    } label: {
                        Text("Done")
                    }
                    .foregroundColor(self.selectedCategory != nil ? self.selectedCategory!.color : .primary)
                }
            }
            
        }
    }
}

struct AddItemSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddItemSheet(selectedCategory: CategoryDSItem.work, items: .constant([]))
    }
}



