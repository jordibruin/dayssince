//
//  AddItemForm.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/25/22.
//

import SwiftUI

struct AddItemForm: View {
    
    @Binding var items: [DSItem]
    @Binding var name: String
    @Binding var date: Date
    @Binding var category: CategoryDSItem?
    @Binding var remindersEnabled: Bool
    
    let reminders = ["Daily", "Weekly", "Monthly"]
    
    @Binding var selectedReminder: DSItemReminders
    
    var accentColor: Color {
        category == nil ? Color.black : category?.color as! Color
    }
    
    @FocusState.Binding var nameIsFocused: Bool
    
    var body: some View {
        if #available(iOS 16.0, *) {
            Background {
                Form {
                    nameSection
                    dateSection
                    newCategorySection
                    reminderSection
                }
                .scrollDismissesKeyboard(.immediately)  // Only available for iOS 16+
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        nameIsFocused = true
                    }
                }
            }
        } else {
            // Fallback on earlier versions
            // TODO: As iOS versions advance, this section should be removed.
            Form {
                nameSection
                dateSection
                newCategorySection
                reminderSection
            }
          // Focus name field when the sheet is opened.
          // On older iOS versions it didn't work if you immediatly focused it so it had to have a slight delay.
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    nameIsFocused = true
                }
            }
        }
    }
    
    var nameSection: some View {
        Section {
            TextField("Name your event", text: $name)
                .focused($nameIsFocused)
                .submitLabel(.done)
        } header: {
            Text("Event Info")
        }
    }
    
    var dateSection: some View {
        Section {
            DatePicker("Event Date", selection: $date, in: ...Date.now, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .accentColor(self.category != nil ? self.category!.color : Color.blue)
        }header: {
            Text("Date")
        }
    }
    
    var reminderSection: some View {
        Section {
            Toggle("Reminders", isOn: $remindersEnabled.animation())
                .tint(self.category != nil ? self.category!.color : Color.green)
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
            ForEach(CategoryDSItem.allCases) { category in
                Button {
                    self.category = category
                } label: {
                    HStack {
                        Image(systemName: category.sfSymbolName)
                            .foregroundColor(self.category == category ? self.category!.color : .primary)
                            .frame(width: 40)
                        
                        Text(category.name)
                        Spacer()
                        
                        if self.category == category {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(self.category!.color)
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

struct Background<Content: View>: View {
    private var content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        Color.white
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(content)
    }
}

// ToDo: fix the preview
//struct AddItemForm_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        AddItemForm(items: .constant([]),
//                    name: .constant(""),
//                    date: .constant(Date.now),
//                    category: .constant(CategoryDSItem.work),
//                    remindersEnabled: .constant(true),
//                    selectedReminder: .constant(DSItemReminders.daily),
//                    nameIsFocused: .constant(false))
//    }
//}

