//
//  CreateFirstEvent.swift
//  DaysSince
//
//  Created by Vicki Minerva on 7/13/22.
//

import SwiftUI
import Defaults

struct CreateFirstEvent: View {
    @Default(.categories) var categories
    @EnvironmentObject var notificationManager: NotificationManager
    
    let navigate: (OnboardingScreen) -> Void
    @State var showCategorySheet: Bool
    @State private var eventName: String
    @State private var eventDate: Date = Date()
    @State var eventCategory: Category
    @State private var eventReminder: DSItemReminders = .none

    init(initialEventName: String, navigate: @escaping (OnboardingScreen) -> Void) {
        self._eventName = State(initialValue: initialEventName)
        self.navigate = navigate
        self._showCategorySheet = State(initialValue: false)
        
        var storedCategories = Defaults[.categories]
        if storedCategories.isEmpty {
            let fallback = Category(name: "Work", emoji: "lightbulb", color: .work)
            storedCategories.append(fallback)
            Defaults[.categories] = storedCategories
        }
        self._eventCategory = State(initialValue: storedCategories.first!)
    }
    
    var accentColor: Color { eventCategory.color.color == .black ? Color.primary :  eventCategory.color.color }
    
    var body: some View {
        ScrollView {
            ProgressBar(progress: 4/8)
            nameHeader
            calendarHeader
            categoryHeader
            reminderHeader
        }
        .padding()
        CustomButton(action: nextPage, label: "Create Event", color: .animalCrossingsGreen)
            .sheet(isPresented: $showCategorySheet) {
                AddCategorySheet()
                    .presentationDragIndicator(.hidden)
                    .presentationDetents([.medium])
                    .presentationCornerRadius(44)
                    .onDisappear {
                        showCategorySheet = false
                    }
            }
    }
        
    private var nameHeader: some View {
        VStack(alignment: .leading) {
            Text("Create your first event")
                .font(.system(.title3, design: .rounded))
                .bold()

            HStack {
                TextField("Enter event name", text: $eventName)
            }
                .padding(12)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(20)
        }
        .padding(.top)
    }
    
    private var calendarHeader: some View {
        VStack(alignment: .leading) {
            Text("When was the last time it happened?")
                .font(.system(.title3, design: .rounded))
                .bold()
            
            DatePicker("Event Date", selection: $eventDate, in: ...Date.now, displayedComponents: .date)
               .datePickerStyle(.graphical)
               .accentColor(accentColor)
        }
        .padding(.top)
    }
    
    private var categoryHeader: some View {
        VStack(alignment: .leading) {
            Text("Pick a category for your event")
                .font(.system(.title3, design: .rounded))
                .bold()
            
            Text("You can add new categories here.")
                .font(.system(.footnote, design: .rounded))
            
            CategoryFormSection(
                selectedCategory: Binding(
                    get: { eventCategory },
                    set: { if let value = $0 { eventCategory = value } }
                ),
                showCategorySheet: $showCategorySheet,
                showHeader: false
            )
            .padding(.top)
        }
        .padding(.top)
    }
    
    
    private var reminderHeader: some View {
        VStack(alignment: .leading) {
            Text("How often would you like to be reminded?")
                .font(.system(.title3, design: .rounded))
                .bold()
            
            Text("A gentle nudge can go a long way.")
                .font(.system(.footnote, design: .rounded))
                .padding(.bottom, 0)
            
            ReminderFormSection(selectedReminder: $eventReminder, accentColor: accentColor)

        }
        .padding(.top)
    }
    
    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince"))
    private var storedItems: [DSItem] = []

    private func nextPage() {
        let remindersEnabled = eventReminder != .none
        let reminderType = eventReminder

        let item = DSItem(
            id: UUID(),
            name: eventName,
            category: eventCategory,
            dateLastDone: eventDate,
            remindersEnabled: remindersEnabled,
            reminder: reminderType
        )

        // Save the item to UserDefaults so FirstEventPreview can display it
        storedItems.append(item)

        if remindersEnabled {
            notificationManager.addReminderFor(item: item)
        }

        print("[Onboarding] Creating item:", item)
        navigate(.screen5)
    }
}

struct CreateFirstEvent_Previews: PreviewProvider {
    static var previews: some View {
        // Ensure preview doesn't crash on empty categories
        if Defaults[.categories].isEmpty {
            let fallback = Category(name: "Work", emoji: "💡", color: .work)
            Defaults[.categories] = [fallback]
        }

        return NavigationStack {
            CreateFirstEvent(initialEventName: "🪴 Water the plants") { _ in }
                .environmentObject(NotificationManager.previewInstance)
        }
    }
}


struct ReminderFormSection: View {
    @Binding var selectedReminder: DSItemReminders
    let accentColor: Color

    private func displayName(for option: DSItemReminders) -> String {
            switch option {
            case .none: return "🚫 No reminders"
            case .daily: return "🕰️ Daily"
            case .weekly: return "🗓️ Weekly"
            case .monthly: return "⌛ Monthly"
            }
        }
    
    var body: some View {
        Section {
            VStack(spacing: 8) {
                ForEach(DSItemReminders.allCases) { reminderOption in
                    Button {
                        withAnimation { selectedReminder = reminderOption }
                    } label: {
                        HStack {
                            Text(displayName(for: reminderOption))
                            Spacer()
                            if selectedReminder == reminderOption {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(accentColor)
                            }
                        }
                        .padding(12)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(16)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
}
