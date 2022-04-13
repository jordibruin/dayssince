//
//  CategoryView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/8/22.
//

import SwiftUI

struct CategoryFilteredView: View {
    var color: colorDaysSinceItem
    var categoryName: String
    var emoji: String
    
    @Binding var items: [DaysSinceItem]
    @State var showAddItemSheet: Bool
    @State var editItemSheet: Bool
    @State var tappedItem = DaysSinceItem(name: "Placeholder", emoji: "Placeholder", dateLastDone: Date.now)
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: .init(colors: [color.color.opacity(0.1), color.color.opacity(0.2)]),
                    startPoint: .init(x: 1, y: 0),
                    endPoint: .init(x: 0.0001, y: 0)).ignoresSafeArea()
                
                ScrollView {
                    TaskList
                }
                Spacer()
                VStack {
                    Spacer()
                    Button {
                          showAddItemSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(.title, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(LinearGradient(
                            gradient: .init(colors: [color.color.opacity(0.8), color.color]),
                            startPoint: .init(x: 0.0, y: 0.5),
                            endPoint: .init(x: 0, y: 1)))
                        .clipShape(Capsule())
                        .shadow(color: items.filter{ $0.color.color == color.color}.count < 5 ? color.color : .white, radius: 10, x: 0, y: 5)
                    }
                }
                
                
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddItemSheet) {
            AddItemSheet(items: $items, color: color, colorAccent: color.color)
        }
        .sheet(isPresented: $editItemSheet) {
            EditTappedItemSheet(items: $items, tappedItem: $tappedItem, editItemSheet: $editItemSheet)
        }
    }
        
        var TaskList: some View {
    //        List {
            // This will be problematic for the future. Should add a category property in the DaysSinceItems and filter according that not the color.
                ForEach(self.items, id: \.id) { item in
                    if item.color.color == color.color {
                        EventListItemView(item: item, editItemSheet: $editItemSheet, tappedItem: $tappedItem, colored: true)
//                      Divider().frame(width: 200)
                    }
                }
//                .onDelete(perform: delete)
//                .foregroundColor(.white)
    //        }
        }
}


struct CategoryHeaderView: View {
    
    init(color: Color = .red, categoryName: String = "Category", emoji: String = "icons8-flag-in-hole-48") {
        self.color = color
        self.categoryName = categoryName
        self.emoji = emoji
    }
    
    let color: Color
    let categoryName: String
    let emoji: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(LinearGradient(
                    gradient: .init(colors: [color.opacity(0.7), color]),
                    startPoint: .init(x: 0.0, y: 0),
                  endPoint: .init(x: 0.9, y: 0.8)
                ))
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Image(emoji)
                        .font(.largeTitle)
                    
                    Text(categoryName)
                        .font(.system(.largeTitle, design: .rounded))
                        .bold()
                }
                Spacer()
                VStack {
                    Text("10")
                        .font(.system(.largeTitle, design: .rounded))
                        .bold()
                    Text("events")
                        .font(.system(.title, design: .rounded))
//                        .bold()
                }
            }
            .padding(12)
        }
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(color: color, radius: 10, x: 0, y: 5)
    }
}



struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryFilteredView(color: colorDaysSinceItem.work , categoryName: "placeholder", emoji: "healthCategoryIcon", items: .constant([]), showAddItemSheet: false, editItemSheet: false, tappedItem: DaysSinceItem(name: "Placeholder", emoji: "Placeholder", dateLastDone: Date.now))
    }
}

