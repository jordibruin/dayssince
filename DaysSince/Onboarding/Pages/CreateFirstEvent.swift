//
//  CreateFirstEvent.swift
//  DaysSince
//
//  Created by Vicki Minerva on 7/13/22.
//

import Defaults
import SwiftUI

struct CreateFirstEvent: View {
    @Default(.categories) var categories

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var notificationManager: NotificationManager

    @Binding var hasSeenOnboarding: Bool
    @Binding var selectedPage: Int
    @Binding var items: [DSItem]

    @State private var name: String = ""
    @State var date: Date = .now
    @State var selectedCategory: Category? = nil
    @State var remindersEnabled: Bool = false
    @State var selectedReminder: DSItemReminders = .daily
    @State var showCategorySheet = false

    @FocusState private var nameIsFocused: Bool

    var accentColor: Color { selectedCategory?.color.color ?? Color.black }

    var body: some View {
        Form {
            nameSection
            dateSection
            CategoryFormSection(selectedCategory: $selectedCategory, showCategorySheet: $showCategorySheet)
            reminderSection
            saveButtonSection
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                nameIsFocused = true
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

    var saveButtonSection: some View {
        Section {
            Button {
                // Finish onboarding
                print("Set onboarding to true")

                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()

                hasSeenOnboarding = true

                // Add new item.
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
                HStack {
                    Spacer()
                    Label("Save Event", systemImage: "note.text.badge.plus")
                        .foregroundColor(accentColor)
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
