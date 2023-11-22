//
//  EditTappedItemForm.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/27/22.
//

import SwiftUI

struct EditTappedItemForm: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var notificationManager: NotificationManager

    @Binding var items: [DSItem]
    @Binding var editItemSheet: Bool
    @Binding var tappedItem: DSItem
    @Binding var showCategorySheet: Bool

    var category: Category { tappedItem.category }
    var accentColor: Color { category.color.color }

    @FocusState.Binding var nameIsFocused: Bool
    @State var showConfirmDelete = false

    var body: some View {
        if #available(iOS 16.0, *) {
            Form {
                nameSection
                dateSection
                CategoryFormSection(selectedCategory: Binding(
                    get: { tappedItem.category },
                    set: { tappedItem.category = $0! }
                ), showCategorySheet: $showCategorySheet)
                reminderSection
                deleteButtonSection
            }
            .scrollDismissesKeyboard(.immediately) // Only available for iOS 16+
            .confirmationDialog("Delete Event", isPresented: $showConfirmDelete) {
                Button("Delete", role: .destructive) {
                    deleteEvent()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this event?")
            }
        } else {
            Form {
                nameSection
                dateSection
                CategoryFormSection(selectedCategory: Binding(
                    get: { tappedItem.category },
                    set: { tappedItem.category = $0! }
                ), showCategorySheet: $showCategorySheet)
                reminderSection
                deleteButtonSection
            }
            .confirmationDialog("Delete Event", isPresented: $showConfirmDelete) {
                Button("Delete", role: .destructive) {
                    deleteEvent()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this event?")
            }
        }
    }

    var nameSection: some View {
        Section {
            TextField("Name", text: $tappedItem.name) {
                UIApplication.shared.endEditing()
            }
            .focused($nameIsFocused)
        } header: {
            Text("Name")
        }
    }

    var reminderSection: some View {
        Section {
            Toggle("Reminders", isOn: $tappedItem.remindersEnabled.animation())
                .tint(accentColor)
//                .onChange(of: tappedItem.remindersEnabled) { remindersEnabled in
//
//                    if remindersEnabled {
//                        notificationManager.center.getNotificationSettings { settings in
//                            if settings.authorizationStatus == .notDetermined {
//
//                            } else if settings.authorizationStatus == .authorized {
//
//                            } else {
//                                print("USER HAS NOT GIVEN PERMISSION")
//                                print("NOW WE NEED TO PUSH SOMEONE TO SETTINGS")
//                            }
//                        }
//                    }
//                }

            // Select type of reminder
            if tappedItem.remindersEnabled {
                Picker("Remind me", selection: $tappedItem.reminder) {
                    ForEach(DSItemReminders.allCases.filter { $0 != .none }, id: \.self) {
                        Text($0.name)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

//            if notificationManager.notificationPermissionGiven {
//                Button {
//                 OPEN THE SETTINGS IMMEDIATLY
//                } label: {
//                    Text("Open settings")
//                }
//            }

        } header: {
            Text("Reminders")
        }
    }

    var dateSection: some View {
        Section {
            DatePicker("Event Date", selection: $tappedItem.dateLastDone, in: ...Date.now, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .accentColor(accentColor)
        } header: {
            Text("Date")
        }
    }

    func getItemIndex() -> Int {
        print("Looking for index of tapped item.")
        return items.firstIndex(where: { $0.id == tappedItem.id })!
    }

    var deleteButtonSection: some View {
        Section {
            Button {
                showConfirmDelete = true
            } label: {
                HStack {
                    Spacer()
                    Label("Delete Event", systemImage: "trash")
                        .foregroundColor(Color.red)
                    Spacer()
                }
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }

    func deleteEvent() {
        withAnimation {
            print("🗑 Delete event \(tappedItem.name)")

            let item_index = getItemIndex()

            tappedItem.reminderNotificationID = items[item_index].reminderNotificationID

            // Notification Manager
            notificationManager.deleteReminderFor(item: tappedItem)

            items.remove(at: getItemIndex())

            editItemSheet = false
            dismiss()
        }
    }
}

struct EditTappedItemForm_Previews: PreviewProvider {
    static var previews: some View {
        EditTappedItemForm(items: .constant([]),
                           editItemSheet: .constant(true),
                           tappedItem: .constant(DSItem.placeholderItem()),
                           showCategorySheet: .constant(false),
                           nameIsFocused: FocusState<Bool>().projectedValue)
    }
}
