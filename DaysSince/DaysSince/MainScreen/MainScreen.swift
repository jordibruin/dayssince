//
//  MainScreen.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/23/22.
//

import SwiftUI

struct MainScreen: View {
    
    @State var showAddItemSheet = false
    @State var editItemSheet = false
    @State var tappedItem = DaysSinceItem.placeholderItem()
    
    @Binding var items: [DaysSinceItem]
    @Binding var completedItems: [DaysSinceItem]
    @Binding var favoriteItems: [DaysSinceItem]
    
    
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    SortingMenuView(items: $items)
                }
            })
        }
        .sheet(isPresented: $showAddItemSheet) {
            AddItemSheet(selectedCategory: nil, getReminders: false, items: $items)
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
            // Using .opacity() makes the top of the button transparent but I don't know how to fix it.
            .background(LinearGradient(
                gradient: .init(colors: [Color.workColor.opacity(0.85), Color.workColor]),
                startPoint: .init(x: 0.0, y: 0.5),
                endPoint: .init(x: 0, y: 1)))
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(color: Color.workColor, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen(items: .constant([.placeholderItem()]), completedItems: .constant([]), favoriteItems: .constant([]))
    }
}
