//
//  AddItemSheet.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/28/22.
//

import SwiftUI
import UserNotifications


struct AddItemSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State var date: Date = Date.now
    @State var selectedCategory: categoryDaysSinceItem? = nil
    @State var getReminders: Bool = false
    @State var selectedReminder: DSItemReminders = .none
    
    @FocusState private var nameIsFocused: Bool
    
    @Binding var items: [DaysSinceItem]
    
    var accentColor: Color {
        selectedCategory == nil ? Color.black : selectedCategory?.color as! Color
    }

    var body: some View {
        
        NavigationView {
            ZStack {
                AddItemForm(items: $items, name: $name, date: $date, category: $selectedCategory, getReminders: $getReminders, selectedReminder: $selectedReminder, nameIsFocused: $nameIsFocused)
                Spacer()
                
                VStack {
                    Spacer()
                    addEventButton
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .toolbar(content: {
                toolbarItems
                
            })
        }
    }
    
    var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "x.square")
                }
                .font(.title2)
                .foregroundColor(accentColor)
            }
            
            ToolbarItem(placement: .principal) { // <3>
                Text("Create New Item")
                    .font(.system(.largeTitle, design: .rounded))
                    .bold()
                    .accessibilityAddTraits(.isHeader)
                    .foregroundColor(accentColor)
            }
            
            ToolbarItemGroup(placement: .keyboard){
                Button("Done") {
                    nameIsFocused = false
                }
            }
        }
    }
    
    var addEventButton: some View {
        Button {
           
            items.append(DaysSinceItem(name: name, category: selectedCategory!, dateLastDone: date, getReminders: getReminders))
            print("➕ Added item. Now there are \(items.count) items!")
            
            if let itemAdded = items.last {
                if getReminders {
                    itemAdded.addReminder()
                }
            }
            dismiss()
        } label: {
            Text("Add Event")
                .font(.system(.title, design: .rounded))
                .bold()
                .foregroundColor(.white)
        }
        .padding()
        .background(LinearGradient(
            gradient: .init(colors: [accentColor.opacity(0.8), accentColor]),
            startPoint: .init(x: 0.0, y: 0.5),
            endPoint: .init(x: 0, y: 1)))
        .clipShape(Capsule())
        .shadow(color: accentColor, radius: 10, x: 0, y: 5)
        .disabled(name.isEmpty)
        .disabled(selectedCategory == nil)
    }
    
    
}

struct AddItemSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddItemSheet(selectedCategory: categoryDaysSinceItem.work, items: .constant([]))
    }
}



