//
//  ContentView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/28/22.
//

import SwiftUI


struct ContentView: View {
    @AppStorage("items") var items = [DaysSinceItem]()
    @AppStorage("completedItems") var completedItems = [DaysSinceItem]()
    @AppStorage("favoriteItems") var favoriteItems = [DaysSinceItem]()

    
    var body: some View {
        MainScreen(items: $items, completedItems: $completedItems, favoriteItems: $favoriteItems)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
