//
//  MainScreen.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/23/22.
//

import SwiftUI

struct MainScreen: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var showAddItemSheet = false
    @State var showSettings = false
    @State var editItemSheet = false
    @State var tappedItem = DaysSinceItem.placeholderItem()
    
    @Binding var items: [DaysSinceItem]
    @Binding var completedItems: [DaysSinceItem]
    @Binding var favoriteItems: [DaysSinceItem]
    
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                MainBackgroundView()
                
                ScrollView {
                    TopSection(
                        items: $items,
                        completedItems: $completedItems,
                        favoriteItems: $favoriteItems
                    )
                    .padding(.bottom, 16)
                    
//                     Code to test notifications. 
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
//                            Text(notification.content.title)
//                            Text("\(notification.trigger!)")
//                        }
//
//                        //
//                    }
//                    .padding(.horizontal)
//                    .onAppear {
//                        notificationManager.getPendingNotification()
//
//                    }
                    
                    BottomSection(
                        items: $items,
                        completedItems: $completedItems,
                        favoriteItems: $favoriteItems,
                        editItemSheet: $editItemSheet,
                        tappedItem: $tappedItem
                    )
                }
                .sheet(isPresented: $editItemSheet) {
                    EditTappedItemSheet(
                        items: $items,
                        completedItems: $completedItems,
                        favoriteItems: $favoriteItems,
                        tappedItem: $tappedItem,
                        editItemSheet: $editItemSheet
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
            SettingsScreen()
        }
        
    }

    var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.primary)
                        .imageScale(.large)
                        .accessibilityLabel("Settings")
                        .font(.title2)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                SortingMenuView(items: $items)
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
                gradient: .init(colors: [colorScheme == .dark ? Color.workColor.opacity(0.85).darker(by: 0.1): Color.workColor.opacity(0.85), colorScheme == .dark ? Color.workColor.darker(by: 0.2): Color.workColor]),
                startPoint: .init(x: 0.0, y: 0.5),
                endPoint: .init(x: 0, y: 1)))
            .background(colorScheme == .dark ? Color.black : Color.white)
            .clipShape(Capsule())
            .shadow(color: Color.workColor, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen(items: .constant([.placeholderItem()]), completedItems: .constant([]), favoriteItems: .constant([]))
            .preferredColorScheme(.dark)
    }
}
