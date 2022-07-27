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
    @Binding var isDaysDisplayModeDetailed: Bool
    
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
    
    @ViewBuilder
    var daysAgoText: some View {
        
            if isDaysDisplayModeDetailed {
                
                // Show years, months and days
                if item.daysAgo >= 365 {
                    let years = item.daysAgo / 365
                    let months = (item.daysAgo - years*365) / 30
                    let days = item.daysAgo - years*365 - months*30
                    
                    HStack {
                        VStack {
                            Text("\(years)")
                                .font(.system(.title3, design: .rounded))
                                .bold()
                                .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color)
                            
                            Text(years > 1 ? "years" : "year")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color)
                            
                        }
                        
                        VStack {
                            Text("\(months)")
                                .font(.system(.title3, design: .rounded))
                                .bold()
                                .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color)
                            
                            Text(months > 1 ? "months" : "month")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color)
                            
                        }
                        VStack {
                            Text("\(days)")
                                .font(.system(.title3, design: .rounded))
                                .bold()
                                .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color)
                            
                            Text(days > 1 ? "days" : "day")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color)
                        }
                    }
                    .frame(minWidth: 0)
                    
                    
                // Show months and days
                } else if item.daysAgo >= 30 {
                    
                    
                    let months = item.daysAgo / 30
                    let days = item.daysAgo - months*30
                    
                    HStack {
                        VStack {
                            Text("\(months)")
                                .font(.system(.title3, design: .rounded))
                                .bold()
                                .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color)
                            
                            Text(months > 1 ? "months" : "month")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color)
                            
                        }
                        VStack {
                            Text("\(days)")
                                .font(.system(.title3, design: .rounded))
                                .bold()
                                .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color)
                            
                            Text(days > 1 ? "days" : "day")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(colored || colorScheme == .dark ? .white : item.category.color)
                        }
                    }
                    .frame(minWidth: 0)
                    
                // Only show the days if it's been less than a month.
                } else {
                    
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
                
            // If user just wants to see the days.
            } else {
                
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
                .onTapGesture {
                    withAnimation {
                        isDaysDisplayModeDetailed.toggle()                        
                    }
                }
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
