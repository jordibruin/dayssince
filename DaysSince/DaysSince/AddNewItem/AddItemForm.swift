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
    @Binding var category: Category?
    @Binding var remindersEnabled: Bool
    @Binding var showCategorySheet: Bool

    let reminders = ["Daily", "Weekly", "Monthly"]

    @Binding var selectedReminder: DSItemReminders

    var accentColor: Color {
        category?.color.color ?? Color.black
    }

    @FocusState.Binding var nameIsFocused: Bool

    var body: some View {
        if #available(iOS 16.0, *) {
            Background {
                Form {
                    nameSection
                    dateSection
                    CategoryFormSection(selectedCategory: $category, showCategorySheet: $showCategorySheet)
                    reminderSection
                }
                .scrollDismissesKeyboard(.immediately) // Only available for iOS 16+
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
                CategoryFormSection(selectedCategory: $category, showCategorySheet: $showCategorySheet)
                reminderSection
            }
            // Focus name field when the sheet is opened.
            // On older iOS versions it didn't work if you immediatly focused a field, so it had to have a slight delay.
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
                .accentColor(accentColor)
        } header: {
            Text("Date")
        }
    }

    var reminderSection: some View {
        Section {
            Toggle("Reminders", isOn: $remindersEnabled.animation())
                .tint(accentColor)
            // Select type of reminder
            if remindersEnabled {
                Picker("Remind me", selection: $selectedReminder) {
                    ForEach(DSItemReminders.allCases.filter { $0 != .none }, id: \.self) {
                        Text($0.name)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        } header: {
            Text("Reminders")
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

struct AddItemForm_Previews: PreviewProvider {
    static var previews: some View {
        AddItemForm(items: .constant([]),
                    name: .constant(""),
                    date: .constant(Date.now),
                    category: .constant(Category.placeholderCategory()),
                    remindersEnabled: .constant(true),
                    showCategorySheet: .constant(false),
                    selectedReminder: .constant(DSItemReminders.daily),
                    nameIsFocused: FocusState<Bool>().projectedValue)
    }
}
