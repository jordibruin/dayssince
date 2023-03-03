//
//  CreateFirstEvent.swift
//  DaysSince
//
//  Created by Vicki Minerva on 7/13/22.
//

import SwiftUI

struct CreateFirstEvent: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var notificationManager: NotificationManager
    
    @Binding var hasSeenOnboarding: Bool
    @Binding var selectedPage: Int
    @Binding var items: [DaysSinceItem]
    
    
    @State private var name: String = ""
    @State var date: Date = Date.now
    @State var selectedCategory: CategoryDaysSinceItem? = nil
    @State var remindersEnabled: Bool = false
    @State var selectedReminder: DSItemReminders = .daily
    
    @FocusState private var nameIsFocused: Bool
    
    
    var accentColor: Color {
        selectedCategory == nil ? Color.black : selectedCategory?.color as! Color
    }

    
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
                .submitLabel(.done)
        } header: {
            Text("Event Info")
        }
    }
    
    var dateSection: some View {
        Section {
            DatePicker("Event Date", selection: $date, in: ...Date.now, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .accentColor(self.selectedCategory != nil ? selectedCategory!.color : Color.blue)
        }header: {
            Text("Date")
        }
    }
    
    var reminderSection: some View {
        Section {
            Toggle("Reminders", isOn: $remindersEnabled.animation())
                .tint(self.selectedCategory != nil ? self.selectedCategory!.color : Color.green)
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
                    selectedCategory = category
                } label: {
                    HStack {
                        Image(systemName: category.sfSymbolName)
                            .foregroundColor(selectedCategory == category ? selectedCategory!.color : .primary)
                            .frame(width: 40)
                        
                        Text(category.name)
                        Spacer()
                        
                        if selectedCategory == category {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(selectedCategory!.color)
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
                HStack {
                    Spacer()
                    Label("Save Event", systemImage: "note.text.badge.plus")
                        .foregroundColor(self.selectedCategory != nil ? self.selectedCategory!.color : .primary)
                        .disabled(name.isEmpty)
                    Spacer()
                }
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
    
    
}

struct CreateFirstEvent_Previews: PreviewProvider {
    static var previews: some View {
        CreateFirstEvent(hasSeenOnboarding: .constant(false), selectedPage: .constant(1), items: .constant([]))
            .preferredColorScheme(.light)
    }
}
