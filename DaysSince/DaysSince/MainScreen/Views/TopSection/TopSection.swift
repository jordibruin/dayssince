//
//  TopSection.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/23/22.
//

import SwiftUI

struct TopSection: View {
    @Binding var items: [DaysSinceItem]
    @Binding var completedItems: [DaysSinceItem]
    @Binding var favoriteItems: [DaysSinceItem]
    
    var body: some View {
        Section {
            
            CategoryBlocksView(items: $items, completedItems: $completedItems, favoriteItems: $favoriteItems)
            Spacer()
        }
        .padding(.vertical, 1)
    }
}

struct TopSection_Previews: PreviewProvider {
    static var previews: some View {
        TopSection(items: .constant([]), completedItems: .constant([]), favoriteItems: .constant([]))
    }
}
