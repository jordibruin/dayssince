//
//  ContentView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/28/22.
//

import SwiftUI


struct ContentView: View {
    @AppStorage("items") var items = [DaysSinceItem]()
    
    @State var showAddItemSheet = false
    @State var editItemSheet = false
    @State var tappedItem = DaysSinceItem(name: "Placeholder", emoji: "Placeholder", dateLastDone: Date.now)
//    @State private var item = DaysSinceItem(name: "Test", emoji: "😎", dateLastDone: Date.now)
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: .init(colors: [Color.backgroundColor.opacity(0.0), Color.backgroundColor]),
                    startPoint: .init(x: 1, y: 0),
                    endPoint: .init(x: 0.0001, y: 0)).ignoresSafeArea()
                
                ScrollView {
                    Section {
                        CategoryBlocksView(items: $items)
                        Spacer()
                    }
                    .padding(.vertical, 1)
                    Divider().frame(width: 200)
                    Section {
                        Spacer()
                        TaskList
                    }
                    .padding(.vertical,1)
                }
                
                VStack {
                    Spacer()
                    Button {
                          showAddItemSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(.title, design: .rounded))
                                .foregroundColor(.white)
                            Text("Add New Event")
//                                .font(.title)
                                .font(.system(.title, design: .rounded))
                                .bold()
                                .foregroundColor(.white)
                        }
                        .padding()
                        // Using .opacity() makes the top of the button transparent but I don't know how to fix it.
                        .background(LinearGradient(
                            gradient: .init(colors: [Color.workColor.opacity(0.8), Color.workColor]),
                            startPoint: .init(x: 0.0, y: 0.5),
                            endPoint: .init(x: 0, y: 1)))
                        .clipShape(Capsule())
                        .shadow(color: Color.workColor, radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Days Since")
            .toolbar(content: {
                toolbarItems
            })
        }
        .sheet(isPresented: $showAddItemSheet) {
            AddItemSheet(items: $items, color: colorDaysSinceItem.work)
        }
        .sheet(isPresented: $editItemSheet) {
            EditTappedItemSheet(items: $items, tappedItem: $tappedItem, editItemSheet: $editItemSheet)
        }
    }
    
        var TaskList: some View {
//            List {
                ForEach(self.items, id: \.id) { item in
                    EventListItemView(item: item, editItemSheet: $editItemSheet, tappedItem: $tappedItem, colored: false)
//                      Divider().frame(width: 200)
                }
//            }
        }

    
    func delete(at offsets: IndexSet) {
            items.remove(atOffsets: offsets)
        }
    
    var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    self.items.removeAll()
                } label: {
                    Image(systemName: "trash.fill")
                }
                .font(.title2)
                .foregroundColor(.black)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                SortingMenuView(items: $items)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
