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
    @Binding var category: CategoryDaysSinceItem?
    @Binding var remindersEnabled: Bool
    
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
            newCategorySection
            reminderSection
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                nameIsFocused = true
            }
        }
    }
    
    var nameSection: some View {
        Section {
            TextField("Name your event", text: $name)
                .focused($nameIsFocused)
        } header: {
            Text("Event Info")
        }
    }
    
    var dateSection: some View {
        Section {
            DatePicker("Event Date", selection: $date, in: ...Date.now, displayedComponents: .date)
                .datePickerStyle(.graphical)
        }header: {
            Text("Date")
        }
    }
    
    var reminderSection: some View {
        Section {
            Toggle("Reminders", isOn: $remindersEnabled.animation())
            
            // Select type of reminder
            if remindersEnabled {
                Picker("Remind me", selection: $selectedReminder) {
                    ForEach(DSItemReminders.allCases.filter({$0 != .none}), id: \.self) {
                        Text($0.name)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        } header: {
            Text("Reminders")
        }
    }
    
    var newCategorySection: some View {
        Section {
            ForEach(CategoryDaysSinceItem.allCases) { category in
                Button {
                    self.category = category
                } label: {
                    HStack {
                        Image(category.emoji)
                            .resizable()
                            .frame(width: 32, height: 32)
                        
                        Text(category.name)
                        Spacer()
                        
                        if self.category == category {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        } header: {
            Text("Category")
        }
    }
}

//struct AddItemForm_Previews: PreviewProvider {
//    static var previews: some View {
//        AddItemForm(items: .constant([]), name: .cont, date: <#T##Binding<Date>#>, category: <#T##Binding<CategoryDaysSinceItem?>#>, getReminders: <#T##Binding<Bool>#>, selectedReminder: <#T##Binding<DSItemReminders>#>, nameIsFocused: <#T##FocusState<Bool>.Binding#>
////        AddItemForm(items: .constant([]), name: .constant(""), date: .constant(Date.now), category: .constant(CategoryDaysSinceItem.work), getReminders: .constant(true), selectedReminder: .constant("Daily"))
//    }
//}

