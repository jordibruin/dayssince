//
//  AddItemSheet.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/28/22.
//

import SwiftUI

struct AddItemSheet: View {
    @Binding var items: [DaysSinceItem]
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State var emoji = ""
    @State var date = Date.now
    @State var color: colorDaysSinceItem
    @State var colorAccent = colorDaysSinceItem.work.color
    
    var body: some View {
        
        NavigationView {
            ZStack {
                FormView(items: $items, name: $name,  emoji: $emoji, date: $date, color: $color, colorAccent: $colorAccent)
                Spacer()
                
                VStack {
                    Spacer()
                    
                    Button {
                        let item = DaysSinceItem(name: name, emoji: emoji, dateLastDone: date, color: color)
                        items.append(item)
                        dismiss()
                    } label: {
                        Text("Add Event")
                            .font(.system(.title, design: .rounded))
                            .bold()
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(LinearGradient(
                        gradient: .init(colors: [colorAccent.opacity(0.8), colorAccent]),
                        startPoint: .init(x: 0.0, y: 0.5),
                        endPoint: .init(x: 0, y: 1)))
                    .clipShape(Capsule())
                    .shadow(color: colorAccent, radius: 10, x: 0, y: 5)
                    .disabled(name.isEmpty)
                }
            
                    
                }
            // How do I make the title centered below the toolbar items?
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "x.square")
                    }
                    .font(.title2)
                    .foregroundColor(colorAccent)
                }
                
                ToolbarItem(placement: .principal) { // <3>
                    Text("Create New Event")
                        .font(.system(.largeTitle, design: .rounded))
                        .bold()
                        .accessibilityAddTraits(.isHeader)
                        .foregroundColor(colorAccent)
                        
                }
            })
        }
    }
}

struct AddItemSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddItemSheet(items: .constant([]), color: colorDaysSinceItem.work)
    }
}


struct FormView: View {
    @Binding var items: [DaysSinceItem]
//    @Environment(\.dismiss) var dismiss
    @Binding var name: String
    @Binding var emoji: String
    @Binding var date: Date
    @Binding var color: colorDaysSinceItem // = colorDaysSinceItem.work
    @Binding var colorAccent: Color
    @FocusState private var nameIsFocused: Bool
    
    var body: some View {
        Form {
            Section {
                TextField("Name your event", text: $name)
                    .focused($nameIsFocused)
                    .font(.system(.title2, design: .rounded))
            }
            
            Section {
                DatePicker("Date", selection: $date)
                    .font(.system(.title2, design: .rounded))
                    .foregroundColor(colorAccent)
            }
            
            Section {
                VStack {
                    Text("Select Category")
                        .font(.system(.title, design: .rounded))
                        .accessibilityAddTraits(.isHeader)
                        .foregroundColor(colorAccent)
                    HStack(alignment: .top, spacing: 0) {
                        VStack {
                            CategorySelectionView(color: Color.workColor, name: "Work", emoji: "workCategoryIcon")
                                .onTapGesture {
                                    color = colorDaysSinceItem.work
                                    emoji = "workCategoryIcon"
                                    colorAccent = color.color
                                }
                            CategorySelectionView(color: Color.lifeColor, name: "Life", emoji: "lifeCategoryIcon")
                                .onTapGesture {
                                    color = colorDaysSinceItem.life
                                    emoji = "lifeCategoryIcon"
                                    colorAccent = color.color
                                }
                        }
                        VStack {
                            CategorySelectionView(color: Color.healthColor, name: "Health", emoji: "healthCategoryIcon")
                                .onTapGesture {
                                    color = colorDaysSinceItem.health
                                    emoji = "healthCategoryIcon"
                                    colorAccent = color.color
                                }
                            CategorySelectionView(color: Color.hobbiesColor, name: "Hobbies", emoji: "hobbiesCategoryIcon")
                                .onTapGesture {
                                    color = colorDaysSinceItem.hobbies
                                    emoji = "hobbiesCategoryIcon"
                                    colorAccent = color.color
                                }
                        }
                    }
                }
            }
            .padding(.vertical)
            .listRowBackground(Color.clear)
    }
}


}


