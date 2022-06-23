//
//  EventListView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 4/7/22.
//

import SwiftUI

struct IndividualItemView: View {
    var item: DaysSinceItem
    @Binding var editItemSheet: Bool
    @Binding var tappedItem: DaysSinceItem
    var colored: Bool
    var isFavorite: Bool
    
    var body: some View {
        Section {
            ZStack(alignment: .topTrailing) {
                Spacer()
                itemBody
                if isFavorite {
                    favoriteSymbol
                        .offset(x:-4, y: -4)
                }
                
            }
        }
    }
    
    var itemBody: some View {
        ZStack(alignment: .leading) {
            backgroundColor
            itemContent
        }
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .overlay(RoundedRectangle(cornerRadius: 25).stroke(item.category.color, lineWidth: 5))
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 0)
        .onTapGesture {
                print("Tapped item \(item)")
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
                .font(.system(.largeTitle, design: .rounded))
                .bold()
                .foregroundColor(colored ? .white : item.category.color)
    }
    
    var daysAgoText: some View {
        VStack {
            Text("\(item.daysAgo)")
                .font(.system(size:50, design: .rounded))
                .bold()
                .foregroundColor(colored ? .white : item.category.color)
            
            Text("days ago")
                .font(.system(.title2, design: .rounded))
                .foregroundColor(colored ? .white : item.category.color)
        }
    }
    
    @ViewBuilder
    var backgroundColor: some View {
        if colored {
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

struct IndividualItemView_Preview: PreviewProvider {
    static var previews: some View {
        IndividualItemView(item: DaysSinceItem.placeholderItem(), editItemSheet: .constant(false), tappedItem: .constant(DaysSinceItem.placeholderItem()), colored: false, isFavorite: true)
    }
}
