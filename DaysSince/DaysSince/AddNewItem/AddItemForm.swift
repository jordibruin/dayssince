//
//  AddItemForm.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/25/22.
//

import SwiftUI

struct AddItemForm: View {
    
    @Binding var items: [DaysSinceItem]
    @Binding var name: String
    @Binding var date: Date
    @Binding var category: categoryDaysSinceItem?
    @Binding var getReminders: Bool
    
    let reminders = ["Daily", "Weekly", "Monthly"]
    
    @Binding var selectedReminder: DSItemReminders
    
    var accentColor: Color {
        category == nil ? Color.black : category?.color as! Color
    }
    
    @FocusState.Binding var nameIsFocused: Bool
    
    var body: some View {
        Form {
            nameSection
            dateSection
            reminderSection
            categorySection
        }
    }
    
    var nameSection: some View {
        Section {
            TextField("Name your event", text: $name)
                .focused($nameIsFocused)
                .font(.system(.title2, design: .rounded))
        }
    }
    
    var dateSection: some View {
        Section {
            DatePicker("Date", selection: $date, in: ...Date.now, displayedComponents: .date)
                .font(.system(.title2, design: .rounded))
                .foregroundColor(accentColor)
        }
    }
    
    var reminderSection: some View {
        Section {
            Toggle("Reminders?", isOn: $getReminders.animation())
            
            // Select type of reminder
            if getReminders {
                Picker("Remind me", selection: $selectedReminder) {
                    ForEach(DSItemReminders.allCases.filter({$0 != .none}), id: \.self) {
                        Text($0.name)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
    
    var categorySection: some View {
        Section {
            VStack {
                Text("Select Category")
                    .font(.system(.title, design: .rounded))
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(accentColor)
                
                CategoriesGridView(selectedCategory: $category, addItem: true)
            }
        }
        .padding(.vertical)
        .listRowBackground(Color.clear)
    }
}

//struct AddItemForm_Previews: PreviewProvider {
//    static var previews: some View {
//        AddItemForm(items: .constant([]), name: .constant(""), date: .constant(Date.now), category: .constant(categoryDaysSinceItem.work), getReminders: .constant(true), selectedReminder: .constant("Daily"))
//    }
//}

