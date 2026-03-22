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
    @EnvironmentObject var dataSyncManager: DataSyncManager

    @State var showAddItemSheet = false
    @State var showAddCategorySheet = false
    @State var showSettings = false
    @State var editItemSheet = false
    @State var tappedItem: DSItem = .placeholderItem()
    @State var showThemeSheet = false
    @State var showiCloudStorageAlert = false
    @State var showSupportScreen = false

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

            }
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarItems
                bottomToolbarItems
            }
        }
        .navigationViewStyle(.stack)
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
        .sheet(isPresented: $showAddCategorySheet) {
            AddCategorySheet()
        }
        .sheet(isPresented: $showSupportScreen) {
            NavigationView {
                SupportScreen()
            }
        }
        .onChange(of: dataSyncManager.showiCloudStorageWarning) { warning in
            if warning {
                showiCloudStorageAlert = true
            }
        }
        .alert("iCloud Storage Almost Full", isPresented: $showiCloudStorageAlert) {
            Button("Contact Us") {
                showSupportScreen = true
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your events data is approaching the iCloud sync limit. Your events are safe on this device, but syncing to other devices may stop working. Please contact us so we can help.")
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

    var bottomToolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()

            Button {
                showAddCategorySheet = true
            } label: {
                Label("New Category", systemImage: "folder.badge.plus")
            }

//            Spacer()

            Button {
                showAddItemSheet = true
            } label: {
                Label("New Event", systemImage: "plus")
            }

            Spacer()
        }
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
