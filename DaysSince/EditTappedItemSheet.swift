//
//  EditTappedItemSheet.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/4/22.
//

import SwiftUI

struct EditTappedItemSheet: View {
    @Binding var items: [DaysSinceItem]
    @Binding var tappedItem: DaysSinceItem
    @Environment(\.dismiss) var dismiss
    @Binding var editItemSheet: Bool
    var body: some View {
        NavigationView {
            ZStack {
                FormViewEditItem(items: $items, tappedItem: $tappedItem, editItemSheet: $editItemSheet)
                
                Spacer()
                VStack {
                    Spacer()
                    
                    
                    Button {
                        var item_index = getItemIndex()
                        items[item_index].name = tappedItem.name
                        items[item_index].emoji = tappedItem.emoji
                        items[item_index].dateLastDone = tappedItem.dateLastDone
                        items[item_index].color = tappedItem.color
                        editItemSheet = false
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.system(.title, design: .rounded))
                            .bold()
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(LinearGradient(
                        gradient: .init(colors: [tappedItem.color.color.opacity(0.8), tappedItem.color.color]),
                        startPoint: .init(x: 0.0, y: 0.5),
                        endPoint: .init(x: 0, y: 1)))
                    .clipShape(Capsule())
                    .shadow(color: tappedItem.color.color, radius: 10, x: 0, y: 5)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "x.square")
                    }
                    .font(.title2)
                    .foregroundColor(tappedItem.color.color)
                }
                   
                ToolbarItem(placement: .principal) { // <3>
                    Text("\(tappedItem.name)")
                        .font(.system(.largeTitle, design: .rounded))
                        .bold()
                        .accessibilityAddTraits(.isHeader)
                        .foregroundColor(tappedItem.color.color)
                }
            })
        }
    }
    
    func getItemIndex() -> Int {
        return items.firstIndex(where: {$0.id == tappedItem.id})!
    }
}

struct EditTappedItemSheet_Previews: PreviewProvider {
    static var previews: some View {
        EditTappedItemSheet(items: .constant([]), tappedItem: .constant(DaysSinceItem(name: "Placeholder", emoji: "Placeholder", dateLastDone: Date.now, color: colorDaysSinceItem.work)), editItemSheet: .constant(false))
    }
}


struct FormViewEditItem: View {
    @Environment(\.dismiss) var dismiss
    @Binding var items: [DaysSinceItem]
    @Binding var tappedItem: DaysSinceItem
    @FocusState private var nameIsFocused: Bool
    @Binding var editItemSheet: Bool
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $tappedItem.name)
                    .focused($nameIsFocused)
                    .font(.system(.title2, design: .rounded))
            }
            
            Section {
                DatePicker("Date", selection: $tappedItem.dateLastDone)
                    .font(.system(.title2, design: .rounded))
                    .foregroundColor(tappedItem.color.color)
            }
            Section {
                VStack {
                    VStack {
                        Text("Select Category")
                            .font(.system(.title, design: .rounded))
                            .accessibilityAddTraits(.isHeader)
                            .foregroundColor(tappedItem.color.color)
                        HStack(alignment: .top, spacing: 0) {
                            VStack {
                                CategorySelectionView(color: Color.workColor, name: "Work", emoji: "workCategoryIcon")
                                    .onTapGesture {
                                        tappedItem.color = colorDaysSinceItem.work
                                        tappedItem.emoji = "workCategoryIcon"
                                    }
                                CategorySelectionView(color: Color.lifeColor, name: "Life", emoji: "lifeCategoryIcon")
                                    .onTapGesture {
                                        tappedItem.color = colorDaysSinceItem.life
                                        tappedItem.emoji = "lifeCategoryIcon"
                                    }
                            }
                            VStack {
                                CategorySelectionView(color: Color.healthColor, name: "Health", emoji: "healthCategoryIcon")
                                    .onTapGesture {
                                        tappedItem.color = colorDaysSinceItem.health
                                        tappedItem.emoji = "healthCategoryIcon"
                                    }
                                CategorySelectionView(color: Color.hobbiesColor, name: "Hobbies", emoji: "hobbiesCategoryIcon")
                                    .onTapGesture {
                                        tappedItem.color = colorDaysSinceItem.hobbies
                                        tappedItem.emoji = "hobbiesCategoryIcon"
                                    }
                            }
                        }
                    }
                    .padding(.vertical)
                    Spacer()
                    Button {
                        var item_index = getItemIndex()
                        items.remove(at: item_index)
                        editItemSheet = false
                        dismiss()
                    } label: {
                        Text("Delete Event")
                            .font(.system(.title, design: .rounded))
                            .bold()
                            .foregroundColor(tappedItem.color.color)
                            .padding()
                    }
                    .padding([.top, .bottom], 10)
                    .background(.white)
                    .foregroundColor(tappedItem.color.color)
                    // This is the key part, we are using both an overlay as well as cornerRadius
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(tappedItem.color.color, lineWidth: 1)
                )
//                    .padding()
//                    .background(LinearGradient(
//                        gradient: .init(colors: [tappedItem.color.color.opacity(0.8), tappedItem.color.color]),
//                        startPoint: .init(x: 0.0, y: 0.5),
//                        endPoint: .init(x: 0, y: 1)))
//                    .clipShape(Capsule())
//                    .shadow(color: tappedItem.color.color, radius: 10, x: 0, y: 5)
                }
            }
            .padding(.vertical, 4)
            .listRowBackground(Color.clear)
        }
    }
    
    func getItemIndex() -> Int {
        return items.firstIndex(where: {$0.id == tappedItem.id})!
    }
}
