//
//  HighlightedItemView.swift
//  Supporter
//
//  Created by Jordi Bruin on 01/12/2021.
//

import SwiftUI

struct HighlightedItemView: View {
    
    let item: HighlightedItem
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        if !sizeCategory.isAccessibilityCategory {
            regularView
        } else {
            accessibleView
        }
    }
    
    var emoji: some View {
        Text(item.emoji ?? "")
            .font(.title2)
            .padding(.leading, -8)
    }
    
    var icon: some View {
        Image(systemName: item.imageName)
            .font(.title)
            .foregroundColor(item.color?.color)
            .padding(.leading, -8)
    }
    
    var text: some View {
        VStack(alignment: .leading) {
            Text(item.title)
                .foregroundColor(Design.listTitleColor)
                .bold()
            if !item.subtitle.isEmpty {
                Text(item.subtitle)
                    .foregroundColor(Design.listTextColor)
                    .font(.caption)
                    .opacity(0.8)
            }
        }
        .padding(.vertical, 12)
        .padding(.trailing, 4)
    }
    
    var regularView: some View {
        HStack {
            if item.emoji != nil {
                emoji
            } else {
                icon
            }
            text
        }
    }
    
    var accessibleView: some View {
        VStack(alignment: .leading, spacing: 0) {
            if item.emoji != nil {
                emoji
            } else {
                icon
            }
            text
        }
    }
}

struct HighlightedItemView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightedItemView(item: HighlightedItem.example)
    }
}
