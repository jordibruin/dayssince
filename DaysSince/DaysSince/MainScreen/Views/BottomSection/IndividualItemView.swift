//
//  EventListView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/7/22.
//

import SwiftUI

struct IndividualItemView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var editItemSheet: Bool
    @Binding var tappedItem: DaysSinceItem
    
    var item: DaysSinceItem
    var colored: Bool
    var isFavorite: Bool
    
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            itemBody
            if isFavorite {
                favoriteSymbol
                    .offset(x:-4, y: -4)
            }
        }
    }
    
    var itemBody: some View {
        ZStack(alignment: .leading) {
            backgroundColor
            itemContent
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    colorScheme == .dark ? item.category.color.darker() : item.category.color,
                    lineWidth: 3
                )
        )
//        .contextMenu {
//            Button {
//                
//            } label: {
//                Text("Delete")
//            }
//        }
        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 0)
        .onTapGesture {
            editItemSheet = true
            tappedItem = item
        }
    }
    
    var favoriteSymbol: some View {
        Image(systemName: "heart.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, alignment: .topTrailing)
            .foregroundColor(Color.red)
            .background(.white)
            .clipShape(Circle())
    }
    
    var nameText: some View {
        Text(item.name)
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color)
    }
    
    var daysAgoText: some View {
        VStack {
            Text("\(item.daysAgo)")
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color)
            
            Text(item.daysAgo > 1 ? "days" : "day")
                .font(.system(.body, design: .rounded))
                .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color)
        }
        .frame(minWidth: 0)
    }                                                                                                                                                                                         
    
    @ViewBuilder
    var backgroundColor: some View {
        if colorScheme == .dark{
            item.category.color.lighter(by: 0.04)
        } else if colored {
            item.category.color
        } else {
            Color.white
        }
    }
    
    var itemContent: some View {
        HStack {
            nameText
            Spacer()
            daysAgoText
        }
        .padding()
    }
    
}

//struct IndividualItemView_Preview: PreviewProvider {
//    static var previews: some View {
//        IndividualItemView(colorScheme: DaysSinceItem.placeholderItem(), editItemSheet: .constant(false), tappedItem: .constant(DaysSinceItem.placeholderItem()), item: false, colored: true, isFavorite: <#Bool#>)
//            .frame(height: 10)
//    }
//}
