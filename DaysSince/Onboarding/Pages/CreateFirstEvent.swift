//
//  CreateFirstEvent.swift
//  DaysSince
//
//  Created by Vicki Minerva on 7/13/22.
//
// TODO: Delete
//import Defaults
//import SwiftUI
//
//struct CreateFirstEvent: View {
//    @Default(.categories) var categories
//
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var notificationManager: NotificationManager
//
//    @Binding var hasSeenOnboarding: Bool
//    @Binding var selectedPage: Int
//    @Binding var items: [DSItem]
//
//    @State private var name: String = ""
//    @State var date: Date = .now
//    @State var selectedCategory: Category? = nil
//    @State var remindersEnabled: Bool = false
//    @State var selectedReminder: DSItemReminders = .daily
//    @State var showCategorySheet = false
//
//    @FocusState private var nameIsFocused: Bool
//
//    var accentColor: Color { selectedCategory?.color.color ?? Color.black }
//
//    var body: some View {
//        Form {
//            nameSection
//            dateSection
//            CategoryFormSection(selectedCategory: $selectedCategory, showCategorySheet: $showCategorySheet)
//            reminderSection
//            saveButtonSection
//        }
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
//                nameIsFocused = true
//            }
//        }
//        .sheet(isPresented: $showCategorySheet) {
//            AddCategorySheet()
//                .presentationDragIndicator(.hidden)
//                .presentationDetents([.medium])
//                .presentationCornerRadius(44)
//                .onDisappear { showCategorySheet = false }
//        }
//    }
//
//    var nameSection: some View {
//        Section {
//            TextField("Name your event", text: $name)
//                .focused($nameIsFocused)
//                .submitLabel(.done)
//        } header: {
//            Text("Event Info")
//        }
//    }
//
//    var dateSection: some View {
//        Section {
//            DatePicker("Event Date", selection: $date, in: ...Date.now, displayedComponents: .date)
//                .datePickerStyle(.graphical)
//                .accentColor(accentColor)
//        } header: {
//            Text("Date")
//        }
//    }
//
//    var reminderSection: some View {
//        Section {
//            Toggle("Reminders", isOn: $remindersEnabled.animation())
//                .tint(accentColor)
//            // Select type of reminder
//            if remindersEnabled {
//                Picker("Remind me", selection: $selectedReminder) {
//                    ForEach(DSItemReminders.allCases.filter { $0 != .none }, id: \.self) {
//                        Text($0.name)
//                    }
//                }
//                .pickerStyle(SegmentedPickerStyle())
//            }
//        } header: {
//            Text("Reminders")
//        }
//    }
//
//    var saveButtonSection: some View {
//        Section {
//            Button {
//                // Finish onboarding
//                print("Set onboarding to true")
//
//                let generator = UIImpactFeedbackGenerator(style: .medium)
//                generator.impactOccurred()
//
//                hasSeenOnboarding = true
//
//                // Add new item.
//                let newItem = DSItem(
//                    id: UUID(),
//                    name: name,
//                    category: selectedCategory ?? categories.first!,
//                    dateLastDone: date,
//                    remindersEnabled: remindersEnabled
//                )
//
//                items.append(newItem)
//
//                if newItem.remindersEnabled {
//                    notificationManager.addReminderFor(item: newItem)
//                }
//
//                print("➕ Added item. Now there are \(items.count) items!")
//
//                dismiss()
//            } label: {
//                HStack {
//                    Spacer()
//                    Label("Save Event", systemImage: "note.text.badge.plus")
//                        .foregroundColor(accentColor)
//                        .disabled(name.isEmpty)
//                    Spacer()
//                }
//            }
//            .buttonStyle(BorderlessButtonStyle())
//        }
//    }
//}
//
//struct CreateFirstEvent_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateFirstEvent(hasSeenOnboarding: .constant(false), selectedPage: .constant(1), items: .constant([]))
//            .preferredColorScheme(.light)
//    }
//}

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
    @State private var eventReminder: ReminderOption = .none
   
    enum ReminderOption: String, CaseIterable, Identifiable {
        case none = "No Reminders"
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"

        var id: String { rawValue }

        var isEnabled: Bool {
            self != .none
        }

        var reminderType: DSItemReminders {
            switch self {
            case .none: return .none
            case .daily: return .daily
            case .weekly: return .weekly
            case .monthly: return .monthly
            }
        }
    }

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
                showCategorySheet: $showCategorySheet
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
    
    private func nextPage() {
        let remindersEnabled = eventReminder.isEnabled
        let reminderType = eventReminder.reminderType

        let item = DSItem(
            id: UUID(),
            name: eventName,
            category: eventCategory/* your selected category */,
            dateLastDone: eventDate,
            remindersEnabled: remindersEnabled,
            reminder: reminderType
        )

        print("Creating item:", item)
//        navigate(.screen4)
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
    @Binding var selectedReminder: CreateFirstEvent.ReminderOption
    let accentColor: Color

    var body: some View {
        Section {
            VStack(spacing: 8) {
                ForEach(CreateFirstEvent.ReminderOption.allCases) { option in
                    Button {
                        withAnimation { selectedReminder = option }
                    } label: {
                        HStack {
                            Text(option.rawValue)
                            Spacer()
                            if selectedReminder == option {
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
