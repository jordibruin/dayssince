//
//  MainScreen.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/23/22.
//

import Defaults
import SwiftUI

struct MainScreen: View {
    @Default(.categories) var categories
    @Default(.mainColor) var mainColor
    @Default(.backgroundColor) var backgroundColor

    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var categoryManager: CategoryManager

    @State var showAddItemSheet = false
    @State var showSettings = false
    @State var editItemSheet = false
    @State var tappedItem: DSItem = .placeholderItem()
    @State var showThemeSheet = false

    @Binding var items: [DSItem]
    @Binding var isDaysDisplayModeDetailed: Bool

    var body: some View {
        NavigationView {
            ZStack {
                MainBackgroundView()

                ScrollView {
                    TopSection(
                        items: $items,
                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed
                    )
                    .padding([.top, .bottom], 16)

//                    Code is used to test the notifications.
//                    VStack(alignment: .leading) {
//                        HStack {
//                            Text("Notification Testing Center")
//                                .bold()
//                            Spacer()
//                        }
//
//                        Button {
//                            notificationManager.getPendingNotification()
//                        } label: {
//                            Text("Check notifications")
//                        }
//                        .buttonStyle(.borderedProminent)
//
//                        ForEach(notificationManager.pendingNotifications, id: \.self) { notification in
//                            Text("🔔 for event: \(notification.content.title)")
//                            Text("\(notification.trigger!)")
//                        }
//                    }
//                    .padding(.horizontal)
//                    .onAppear {
//                        notificationManager.getPendingNotification()
//                    }

                    BottomSection(
                        items: $items,
                        editItemSheet: $editItemSheet,
                        tappedItem: $tappedItem,
                        isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed
                    )
                }
                .sheet(isPresented: $editItemSheet) {
                    EditTappedItemSheet(
                        items: $items,
                        editItemSheet: $editItemSheet,
                        tappedItem: $tappedItem
                    )
                }

                VStack {
                    Spacer()
                    addNewEventButton
                }
            }
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                toolbarItems
            })
        }
        .sheet(isPresented: $showAddItemSheet) {
            AddItemSheet(selectedCategory: nil, remindersEnabled: false, items: $items)
        }
        .sheet(isPresented: $showSettings) {
            SettingsScreen(isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed, showSettings: $showSettings)
        }
        .sheet(isPresented: $showThemeSheet) {
            ThemeView()
                .presentationDetents([.medium])
                .presentationCornerRadius(32)
                .onDisappear { showThemeSheet = false }
        }
    }

    var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(colorScheme == .dark ? .primary : mainColor.opacity(0.8))
                        .imageScale(.large)
                        .accessibilityLabel("Settings")
                        .font(.title2)
                }
            }

            ToolbarItem(placement: .navigationBarLeading) {
                SortingMenuView(items: $items)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showThemeSheet = true
                } label: {
                    Image(systemName: "paintpalette.fill")
                        .foregroundColor(colorScheme == .dark ? .primary : mainColor.opacity(0.8))
                        .imageScale(.large)
                        .accessibilityLabel("Change theme")
                        .font(.title2)
                }
            }
        }
    }

    var addNewEventButton: some View {
        Button {
            showAddItemSheet = true
        } label: {
            HStack {
                Image(systemName: "plus")
                    .font(.system(.title2, design: .rounded))
                    .foregroundColor(.white)
                Text("Add New Event")
                    .font(.system(.title2, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
            }
            .padding()
            .background(LinearGradient(
                gradient: .init(colors: [colorScheme == .dark ? mainColor.opacity(0.85).darker(by: 0.1) : mainColor.opacity(0.85), colorScheme == .dark ? mainColor.darker(by: 0.2) : mainColor]),
                startPoint: .init(x: 0.0, y: 0.5),
                endPoint: .init(x: 0, y: 1)
            ))
            .background(colorScheme == .dark ? Color.black : Color.white)
            .clipShape(Capsule())
            .shadow(color: mainColor, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.bottom, 16)
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen(
            items: .constant([.placeholderItem()]),
            isDaysDisplayModeDetailed: .constant(false)
        )
        .preferredColorScheme(.light)
    }
}
