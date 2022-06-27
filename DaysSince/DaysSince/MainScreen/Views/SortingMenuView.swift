//
//  SortingMenuView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/4/22.
//

import SwiftUI

struct SortingMenuView: View {
    @Binding var items: [DaysSinceItem]
    @State var sortType = "none"
    @State var descending = true
    @State var image = "arrow.down"
    var body: some View {
        
        Menu {
            Button (action: sortAlphabetically){
                if sortType == "az" {
                    Image(systemName: image)
                }
                Text("Name")
            }
            Button (action: sortByDays){
                if sortType == "days" {
                    Image(systemName: image)
                }
                Text("Days Ago")
            }
            Button (action: sortByColor){
                if sortType == "color" {
                    Image(systemName: image)
                }
                Text("Category")
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle.fill")
        }
        .foregroundColor(.black)
    }
    
    
    func sortByDays () {
        
        if sortType == "days" {
            descending.toggle()
        } else {
            descending = true
        }
        if descending {
            items.sort{
                $0.daysAgo > $1.daysAgo
            }
            sortType = "days"
            image = "arrow.down"
        } else {
            items.sort{
                $0.daysAgo < $1.daysAgo
            }
            sortType = "days"
            image = "arrow.up"
        }
    }
    
    func sortAlphabetically() {
        
        if sortType == "az" {
            descending.toggle()
        } else {
            descending = false
        }
        if descending {
            items.sort{
                $0.name > $1.name
            }
            sortType = "az"
            image = "arrow.down"
        } else {
            items.sort{
                $0.name < $1.name
            }
            sortType = "az"
            image = "arrow.up"
        }
    }
    
    func sortByColor() {
        
        if sortType == "color" {
            descending.toggle()
        } else {
            descending = false
        }
        if descending {
            items.sort{
                $0.category.name > $1.category.name
            }
            sortType = "color"
            image = "arrow.down"
        } else {
            items.sort{
                $0.category.name < $1.category.name
            }
            sortType = "color"
            image = "arrow.up"
        }
    }
}

struct SortingMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SortingMenuView(items: .constant([]))
    }
}
