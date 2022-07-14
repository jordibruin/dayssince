//
//  CreateFirstEventForm.swift
//  DaysSince
//
//  Created by Vicki Minerva on 7/14/22.
//

import SwiftUI

struct CreateFirstEventForm: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var notificationManager: NotificationManager
    
    @Binding var items: [DaysSinceItem]
    @Binding var name: String
    @Binding var date: Date
    @Binding var category: CategoryDaysSinceItem?
    @Binding var remindersEnabled: Bool
    @Binding var hasSeenOnboarding: Bool
    @Binding var selectedCategory: CategoryDaysSinceItem?
    
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
            saveButtonSection
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
    
    var saveButtonSection: some View {
        Section {
            Button {
                // Finish onboarding
                print("Set onboarding to true")
                
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                hasSeenOnboarding = true
                
                // Add new item.
                let newItem = DaysSinceItem(
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
                HStack {
                    Spacer()
                    Label("Create First Event", systemImage: "plus")
                        .foregroundColor(Color.red)
                    Spacer()
                }
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

//struct CreateFirstEventForm_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateFirstEventForm()
//    }
//}
